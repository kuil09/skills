#!/usr/bin/env bash
# =============================================================================
# pomodoro-mark-retro.sh — Mark a retrospective as complete
# =============================================================================
# Usage: pomodoro-mark-retro.sh <session>
#
# The agent MUST call this after finishing any retrospective. It writes the
# session number to ~/.pomodoro/retro_done so that pomodoro-check.sh emits
# NO_ACTION for the remainder of that break phase.
#
# Forgetting to call this causes the polling loop to re-trigger the same
# retrospective on every subsequent 30-second tick.
# =============================================================================
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <session>"
  exit 1
fi

SESSION="$1"
STATE_DIR="${POMODORO_STATE_DIR:-$HOME/.pomodoro}"
RETRO_DONE_FILE="$STATE_DIR/retro_done"
LOG_FILE="$STATE_DIR/session.log"

mkdir -p "$STATE_DIR"
echo "$SESSION" > "$RETRO_DONE_FILE"

NOW=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
echo "[$NOW] RETRO_DONE — session $SESSION retrospective complete" >> "$LOG_FILE"
echo "Session $SESSION marked as retrospected."
