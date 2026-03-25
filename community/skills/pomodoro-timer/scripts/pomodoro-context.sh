#!/usr/bin/env bash
# =============================================================================
# pomodoro-context.sh — 에이전트에게 현재 뽀모도로 컨텍스트를 제공하는 스크립트
# =============================================================================
# 이 스크립트는 Claude가 현재 뽀모도로 상태와 세션 로그를 한 번에 파악하기 위해
# 사용합니다. 회고 요청 시 이 스크립트를 먼저 실행하세요.
# =============================================================================
set -euo pipefail

STATE_DIR="${POMODORO_STATE_DIR:-$HOME/.pomodoro}"
STATE_FILE="$STATE_DIR/state.json"
LOG_FILE="$STATE_DIR/session.log"

echo "=== 🍅 뽀모도로 현재 상태 ==="
if [[ -f "$STATE_FILE" ]]; then
  cat "$STATE_FILE"
else
  echo '{"phase":"idle","session":0,"cycle":0}'
fi

echo ""
echo "=== 📋 세션 로그 ==="
if [[ -f "$LOG_FILE" ]]; then
  cat "$LOG_FILE"
else
  echo "(로그 없음)"
fi

echo ""
echo "=== ⏱ 현재 시각 ==="
date -u +"%Y-%m-%dT%H:%M:%SZ"
