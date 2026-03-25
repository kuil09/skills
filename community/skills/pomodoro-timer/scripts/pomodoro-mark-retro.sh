#!/usr/bin/env bash
# =============================================================================
# pomodoro-mark-retro.sh — 회고 완료 표시
# =============================================================================
# Usage: pomodoro-mark-retro.sh <session>
#
# 에이전트가 회고를 마친 후 반드시 이 스크립트를 실행해야 합니다.
# 그렇지 않으면 루프가 같은 세션에 대해 회고를 반복 시도합니다.
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
echo "[$NOW] RETRO_DONE — 세션 $SESSION 회고 완료" >> "$LOG_FILE"
echo "세션 $SESSION 회고 완료로 표시됨"
