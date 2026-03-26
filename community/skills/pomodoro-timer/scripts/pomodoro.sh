#!/usr/bin/env bash
# =============================================================================
# pomodoro.sh — Background Pomodoro timer with machine-readable state output
# =============================================================================
# Usage:
#   pomodoro.sh start    Start a new Pomodoro cycle (kills any existing timer)
#   pomodoro.sh status   Print current state.json + human-readable time left
#   pomodoro.sh stop     Kill the background timer, reset phase to idle
#   pomodoro.sh log      Print the current cycle event log
#
# State is written to $POMODORO_STATE_DIR (default: ~/.pomodoro/) so that
# pomodoro-check.sh and the agent can inspect it at any time.
# =============================================================================
set -euo pipefail

STATE_DIR="${POMODORO_STATE_DIR:-$HOME/.pomodoro}"
STATE_FILE="$STATE_DIR/state.json"
LOG_FILE="$STATE_DIR/session.log"
PID_FILE="$STATE_DIR/timer.pid"

WORK_MIN="${POMODORO_WORK_MIN:-25}"
SHORT_BREAK_MIN="${POMODORO_SHORT_BREAK_MIN:-5}"
LONG_BREAK_MIN="${POMODORO_LONG_BREAK_MIN:-30}"
SESSIONS_BEFORE_LONG="${POMODORO_SESSIONS_BEFORE_LONG:-4}"

mkdir -p "$STATE_DIR"

# ─── helpers ──────────────────────────────────────────────────────────────────

now_epoch() { date +%s; }
now_iso()   { date -u +"%Y-%m-%dT%H:%M:%SZ"; }

write_state() {
  local phase="$1" session="$2" start="$3" end="$4" cycle="$5"
  cat > "$STATE_FILE" <<EOF
{
  "phase": "$phase",
  "session": $session,
  "cycle": $cycle,
  "start_epoch": $start,
  "end_epoch": $end,
  "start_iso": "$(date -u -d @"$start" +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date -u -r "$start" +"%Y-%m-%dT%H:%M:%SZ")",
  "end_iso":   "$(date -u -d @"$end"   +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date -u -r "$end"   +"%Y-%m-%dT%H:%M:%SZ")",
  "updated_iso": "$(now_iso)"
}
EOF
}

log_event() {
  echo "[$(now_iso)] $*" | tee -a "$LOG_FILE"
}

notify() {
  local msg="$1"
  # Desktop notification (best-effort; falls back to terminal bell + banner)
  if command -v notify-send &>/dev/null; then
    notify-send "🍅 Pomodoro" "$msg" 2>/dev/null || true
  fi
  if command -v osascript &>/dev/null; then
    osascript -e "display notification \"$msg\" with title \"🍅 Pomodoro\"" 2>/dev/null || true
  fi
  printf '\a'   # terminal bell
  echo ""
  echo "╔══════════════════════════════════════╗"
  printf  "║  🍅  %-34s║\n" "$msg"
  echo "╚══════════════════════════════════════╝"
  echo ""
}

countdown() {
  local total_sec=$1
  local label="$2"
  local end_epoch=$(( $(now_epoch) + total_sec ))

  while true; do
    local now
    now=$(now_epoch)
    local remaining=$(( end_epoch - now ))
    [[ $remaining -le 0 ]] && break

    local m=$(( remaining / 60 ))
    local s=$(( remaining % 60 ))
    printf "\r  ⏱  %s — %02d:%02d remaining   " "$label" "$m" "$s"
    sleep 1
  done
  printf "\r%-50s\r" ""   # clear line
}

# ─── commands ─────────────────────────────────────────────────────────────────

cmd_status() {
  if [[ ! -f "$STATE_FILE" ]]; then
    echo '{"phase":"idle","session":0,"cycle":0}'
    return
  fi
  cat "$STATE_FILE"

  local phase end_epoch
  phase=$(grep '"phase"' "$STATE_FILE" | sed 's/.*: *"\([^"]*\)".*/\1/')
  end_epoch=$(grep '"end_epoch"' "$STATE_FILE" | sed 's/[^0-9]//g')

  if [[ "$phase" != "idle" && -n "$end_epoch" ]]; then
    local remaining=$(( end_epoch - $(now_epoch) ))
    if [[ $remaining -gt 0 ]]; then
      echo ""
      echo "  → Time remaining: $(( remaining / 60 ))m $(( remaining % 60 ))s"
    else
      echo ""
      echo "  → Phase has already elapsed."
    fi
  fi
}

cmd_log() {
  if [[ ! -f "$LOG_FILE" ]]; then
    echo "No session log found."
    return
  fi
  cat "$LOG_FILE"
}

cmd_stop() {
  if [[ -f "$PID_FILE" ]]; then
    local pid
    pid=$(cat "$PID_FILE")
    if kill -0 "$pid" 2>/dev/null; then
      kill "$pid"
      echo "Timer stopped (PID $pid)"
    fi
    rm -f "$PID_FILE"
  fi
  write_state "idle" 0 0 0 0
  log_event "STOP — timer stopped by user"
  echo "Pomodoro timer stopped."
}

cmd_start() {
  # Kill any existing timer
  if [[ -f "$PID_FILE" ]]; then
    local old_pid
    old_pid=$(cat "$PID_FILE")
    kill "$old_pid" 2>/dev/null || true
    rm -f "$PID_FILE"
  fi

  # Reset log and retro marker for a fresh cycle
  : > "$LOG_FILE"
  rm -f "$STATE_DIR/retro_done"
  log_event "START — new Pomodoro cycle"

  echo "🍅 Pomodoro timer started!"
  echo "   Focus: ${WORK_MIN} min × ${SESSIONS_BEFORE_LONG} sessions per cycle"
  echo "   Short break: ${SHORT_BREAK_MIN} min  |  Long break: ${LONG_BREAK_MIN} min"
  echo ""

  # Run the full cycle loop in the background
  (
    echo $$ > "$PID_FILE"

    local cycle=1
    local session=1

    while true; do
      # ── Focus phase ───────────────────────────────────────────────────────
      local work_sec=$(( WORK_MIN * 60 ))
      local ws
      ws=$(now_epoch)
      local we=$(( ws + work_sec ))
      write_state "work" "$session" "$ws" "$we" "$cycle"
      log_event "WORK_START — session $session (cycle $cycle)"

      notify "Session $session started — focus for ${WORK_MIN} minutes."
      countdown "$work_sec" "Session $session"
      log_event "WORK_END — session $session complete"

      # ── Select break type ─────────────────────────────────────────────────
      if (( session % SESSIONS_BEFORE_LONG == 0 )); then
        # Long break
        local break_sec=$(( LONG_BREAK_MIN * 60 ))
        local bs
        bs=$(now_epoch)
        local be=$(( bs + break_sec ))
        write_state "long_break" "$session" "$bs" "$be" "$cycle"
        log_event "LONG_BREAK_START — ${LONG_BREAK_MIN} min long break (cycle $cycle complete)"

        notify "Cycle $cycle complete! ${LONG_BREAK_MIN}-min long break — the agent will conduct the cycle retrospective."
        countdown "$break_sec" "Long break"
        log_event "LONG_BREAK_END — cycle $cycle long break finished"
        notify "Long break over. Starting a new cycle."

        cycle=$(( cycle + 1 ))
        session=$(( session + 1 ))
      else
        # Short break
        local break_sec=$(( SHORT_BREAK_MIN * 60 ))
        local bs
        bs=$(now_epoch)
        local be=$(( bs + break_sec ))
        write_state "short_break" "$session" "$bs" "$be" "$cycle"
        log_event "SHORT_BREAK_START — ${SHORT_BREAK_MIN} min short break"

        notify "Session $session done! ${SHORT_BREAK_MIN}-min break — the agent will conduct the session retrospective."
        countdown "$break_sec" "Short break"
        log_event "SHORT_BREAK_END — break finished, preparing next session"
        notify "Break over. Get ready for the next session."

        session=$(( session + 1 ))
      fi

      write_state "idle" "$session" "$(now_epoch)" "$(now_epoch)" "$cycle"
    done
  ) &

  local bg_pid=$!
  echo "$bg_pid" > "$PID_FILE"
  echo "  Timer running in background (PID: $bg_pid)"
  echo "  Check status : pomodoro.sh status"
  echo "  Stop timer   : pomodoro.sh stop"
}

# ─── dispatch ─────────────────────────────────────────────────────────────────

case "${1:-status}" in
  start)  cmd_start  ;;
  status) cmd_status ;;
  stop)   cmd_stop   ;;
  log)    cmd_log    ;;
  *)
    echo "Usage: $0 {start|status|stop|log}"
    exit 1
    ;;
esac
