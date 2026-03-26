#!/usr/bin/env bash
# =============================================================================
# pomodoro-context.sh — Full context snapshot for agent inspection
# =============================================================================
# Dumps the current state.json, the full event log, and the current UTC time
# in one shot. The agent uses this for context when conducting retrospectives
# or when a manual status check is requested.
# =============================================================================
set -euo pipefail

STATE_DIR="${POMODORO_STATE_DIR:-$HOME/.pomodoro}"
STATE_FILE="$STATE_DIR/state.json"
LOG_FILE="$STATE_DIR/session.log"

echo "=== 🍅 Current Pomodoro State ==="
if [[ -f "$STATE_FILE" ]]; then
  cat "$STATE_FILE"
else
  echo '{"phase":"idle","session":0,"cycle":0}'
fi

echo ""
echo "=== 📋 Session Event Log ==="
if [[ -f "$LOG_FILE" ]]; then
  cat "$LOG_FILE"
else
  echo "(no log yet)"
fi

echo ""
echo "=== ⏱ Current Time (UTC) ==="
date -u +"%Y-%m-%dT%H:%M:%SZ"
