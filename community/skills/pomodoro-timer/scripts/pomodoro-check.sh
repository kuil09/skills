#!/usr/bin/env bash
# =============================================================================
# pomodoro-check.sh — 에이전트 루프용 회고 필요 여부 감지 스크립트
# =============================================================================
# 출력 형식:
#   RETRO_NEEDED short_break <session> <cycle>
#   RETRO_NEEDED long_break <session> <cycle>
#   NO_ACTION
#
# 에이전트는 이 스크립트를 주기적으로 실행해 RETRO_NEEDED가 출력되면
# 즉시 사용자에게 개입하여 휴식과 회고를 진행해야 합니다.
# =============================================================================
set -euo pipefail

STATE_DIR="${POMODORO_STATE_DIR:-$HOME/.pomodoro}"
STATE_FILE="$STATE_DIR/state.json"
RETRO_DONE_FILE="$STATE_DIR/retro_done"

# 타이머가 실행된 적 없으면 NO_ACTION
if [[ ! -f "$STATE_FILE" ]]; then
  echo "NO_ACTION"
  exit 0
fi

# state.json 파싱
phase=$(grep '"phase"'   "$STATE_FILE" | sed 's/.*: *"\([^"]*\)".*/\1/')
session=$(grep '"session"' "$STATE_FILE" | sed 's/[^0-9]//g' | head -1)
cycle=$(grep '"cycle"'   "$STATE_FILE" | sed 's/[^0-9]//g' | head -1)

# 집중 중이거나 idle 이면 NO_ACTION
if [[ "$phase" != "short_break" && "$phase" != "long_break" ]]; then
  echo "NO_ACTION"
  exit 0
fi

# 이미 이 세션의 회고를 마쳤는지 확인
last_retro="-1"
if [[ -f "$RETRO_DONE_FILE" ]]; then
  last_retro=$(cat "$RETRO_DONE_FILE")
fi

if [[ "$last_retro" == "${session}" ]]; then
  # 이미 처리된 세션
  echo "NO_ACTION"
  exit 0
fi

# 회고 필요 — 종류 출력
echo "RETRO_NEEDED $phase $session $cycle"
