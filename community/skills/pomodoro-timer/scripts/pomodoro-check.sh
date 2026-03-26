#!/usr/bin/env bash
# =============================================================================
# pomodoro-check.sh — Phase transition detector for the agent polling loop
# =============================================================================
# Called by the agent every 30 seconds via /loop. Outputs exactly one line:
#
#   RETRO_NEEDED short_break <session> <cycle>
#   RETRO_NEEDED long_break  <session> <cycle>
#   NO_ACTION
#
# The agent must interrupt immediately when RETRO_NEEDED is received and
# conduct the appropriate retrospective. After completing it, the agent MUST
# call pomodoro-mark-retro.sh to prevent repeated triggers on subsequent ticks.
# =============================================================================
set -euo pipefail

STATE_DIR="${POMODORO_STATE_DIR:-$HOME/.pomodoro}"
STATE_FILE="$STATE_DIR/state.json"
RETRO_DONE_FILE="$STATE_DIR/retro_done"

# No timer has run yet
if [[ ! -f "$STATE_FILE" ]]; then
  echo "NO_ACTION"
  exit 0
fi

# Parse state.json (plain grep/sed — no jq dependency)
phase=$(grep '"phase"'   "$STATE_FILE" | sed 's/.*: *"\([^"]*\)".*/\1/')
session=$(grep '"session"' "$STATE_FILE" | sed 's/[^0-9]//g' | head -1)
cycle=$(grep '"cycle"'   "$STATE_FILE" | sed 's/[^0-9]//g' | head -1)

# Only act on break phases
if [[ "$phase" != "short_break" && "$phase" != "long_break" ]]; then
  echo "NO_ACTION"
  exit 0
fi

# Check whether this session's retrospective is already done
last_retro="-1"
if [[ -f "$RETRO_DONE_FILE" ]]; then
  last_retro=$(cat "$RETRO_DONE_FILE")
fi

if [[ "$last_retro" == "$session" ]]; then
  echo "NO_ACTION"
  exit 0
fi

# Retrospective is needed
echo "RETRO_NEEDED $phase $session $cycle"
