#!/usr/bin/env bash
# =============================================================================
# pomodoro.sh — Pomodoro timer with state tracking for AI agent awareness
# =============================================================================
# Usage:
#   pomodoro.sh start          Start a new Pomodoro cycle
#   pomodoro.sh status         Print current state (JSON)
#   pomodoro.sh stop           Stop the running timer
#   pomodoro.sh log            Show session log for current cycle
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
  # Try desktop notification; fall back to terminal bell + print
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
    local now=$(now_epoch)
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

  # Show human-readable remaining time if a timer is running
  local phase session end_epoch
  phase=$(grep '"phase"' "$STATE_FILE" | sed 's/.*: *"\([^"]*\)".*/\1/')
  end_epoch=$(grep '"end_epoch"' "$STATE_FILE" | sed 's/[^0-9]//g')

  if [[ "$phase" != "idle" && -n "$end_epoch" ]]; then
    local now=$(now_epoch)
    local remaining=$(( end_epoch - now ))
    if [[ $remaining -gt 0 ]]; then
      local m=$(( remaining / 60 ))
      local s=$(( remaining % 60 ))
      echo ""
      echo "  → 남은 시간: ${m}분 ${s}초"
    else
      echo ""
      echo "  → 시간이 이미 경과되었습니다."
    fi
  fi
}

cmd_log() {
  if [[ ! -f "$LOG_FILE" ]]; then
    echo "세션 로그가 없습니다."
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
      echo "타이머 중지 (PID $pid)"
    fi
    rm -f "$PID_FILE"
  fi
  write_state "idle" 0 0 0 0
  log_event "STOP — 타이머가 중지되었습니다"
  echo "뽀모도로 타이머가 중지되었습니다."
}

cmd_start() {
  # Kill any existing timer
  if [[ -f "$PID_FILE" ]]; then
    local old_pid
    old_pid=$(cat "$PID_FILE")
    kill "$old_pid" 2>/dev/null || true
    rm -f "$PID_FILE"
  fi

  # Reset log for new cycle
  : > "$LOG_FILE"
  log_event "START — 새 뽀모도로 사이클 시작"

  echo "🍅 뽀모도로 타이머 시작!"
  echo "   집중: ${WORK_MIN}분 × ${SESSIONS_BEFORE_LONG}회"
  echo "   짧은 휴식: ${SHORT_BREAK_MIN}분, 긴 휴식: ${LONG_BREAK_MIN}분"
  echo ""

  # Run the full cycle in background
  (
    echo $$ > "$PID_FILE"

    local cycle=1
    local session=1

    while true; do
      # ── Work phase ──────────────────────────────────────────────────────────
      local work_sec=$(( WORK_MIN * 60 ))
      local ws=$(now_epoch)
      local we=$(( ws + work_sec ))
      write_state "work" "$session" "$ws" "$we" "$cycle"
      log_event "WORK_START — 세션 $session (사이클 $cycle)"

      notify "세션 $session 집중 시작! ${WORK_MIN}분 동안 집중하세요."
      countdown "$work_sec" "세션 $session 집중"

      log_event "WORK_END — 세션 $session 완료"

      # ── Determine break type ─────────────────────────────────────────────
      if (( session % SESSIONS_BEFORE_LONG == 0 )); then
        # Long break
        local break_sec=$(( LONG_BREAK_MIN * 60 ))
        local bs=$(now_epoch)
        local be=$(( bs + break_sec ))
        write_state "long_break" "$session" "$bs" "$be" "$cycle"
        log_event "LONG_BREAK_START — ${LONG_BREAK_MIN}분 긴 휴식 (사이클 $cycle 완료)"

        notify "사이클 $cycle 완료! ${LONG_BREAK_MIN}분 긴 휴식 — 지금 Claude에게 통합 회고를 요청하세요."
        echo "💡 Claude에게 '통합 회고해줘' 라고 말하세요."
        countdown "$break_sec" "긴 휴식"

        log_event "LONG_BREAK_END — 사이클 $cycle 긴 휴식 완료"
        notify "긴 휴식 종료! 새 사이클을 시작합니다."

        cycle=$(( cycle + 1 ))
        session=$(( session + 1 ))
      else
        # Short break
        local break_sec=$(( SHORT_BREAK_MIN * 60 ))
        local bs=$(now_epoch)
        local be=$(( bs + break_sec ))
        write_state "short_break" "$session" "$bs" "$be" "$cycle"
        log_event "SHORT_BREAK_START — ${SHORT_BREAK_MIN}분 짧은 휴식"

        notify "세션 $session 완료! ${SHORT_BREAK_MIN}분 휴식 — 지금 Claude에게 세션 회고를 요청하세요."
        echo "💡 Claude에게 '세션 회고해줘' 라고 말하세요."
        countdown "$break_sec" "짧은 휴식"

        log_event "SHORT_BREAK_END — 휴식 완료, 다음 세션 준비"
        notify "휴식 종료! 다음 집중 세션을 준비하세요."

        session=$(( session + 1 ))
      fi

      write_state "idle" "$session" "$(now_epoch)" "$(now_epoch)" "$cycle"
    done
  ) &

  local bg_pid=$!
  echo "$bg_pid" > "$PID_FILE"
  echo "  타이머 백그라운드 실행 중 (PID: $bg_pid)"
  echo "  상태 확인: pomodoro.sh status"
  echo "  중지:      pomodoro.sh stop"
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
