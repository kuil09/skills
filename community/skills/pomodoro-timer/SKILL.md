---
name: pomodoro-timer
description: >
  A Pomodoro technique skill for AI agent sessions. Runs a background shell
  timer, detects work/break phase transitions via a polling loop, and drives
  the agent to proactively interrupt the user at every break — conducting a
  short session retrospective (5 min breaks) or a full cycle retrospective
  (30 min long break). The user never has to ask; the agent acts first.
---

# Pomodoro Timer Skill

## Goal

- Run a Pomodoro timer as a background shell process that writes machine-readable
  state to `~/.pomodoro/state.json`.
- Use `/loop 30s` so the agent polls `pomodoro-check.sh` every 30 seconds and
  detects phase transitions automatically.
- **Short break (5 min):** Agent interrupts immediately, forces the user to stop
  working, and conducts a concise 3-question session retrospective.
- **Long break (30 min):** Agent interrupts immediately, declares the cycle
  complete, and produces a consolidated retrospective report for all 4 sessions.
- The user is **never** required to trigger retrospectives manually.

## Pomodoro Cycle

```
[Session 1: 25 min focus] → [5 min short break  + session retrospective]
[Session 2: 25 min focus] → [5 min short break  + session retrospective]
[Session 3: 25 min focus] → [5 min short break  + session retrospective]
[Session 4: 25 min focus] → [30 min long break  + cycle retrospective]
         └──────────────────────────────── 1 cycle ───────────────────┘
```

## Workflow

1. **Start** — Agent asks for the work goal, then launches the timer and the
   polling loop.
2. **Focus session** — Timer counts down in the background. Agent stays silent.
3. **Transition detection** — Every 30 s the loop runs `pomodoro-check.sh`.
   When `RETRO_NEEDED` is emitted, the agent intervenes immediately.
4. **Session retrospective** — Agent interrupts with a break announcement and
   asks 3 questions. Records a compact summary, then marks the session done.
5. **Repeat** — Steps 2-4 repeat for sessions 2 and 3.
6. **Cycle retrospective** — After session 4 the agent declares a long break,
   synthesises all 4 session summaries, asks 3 cycle-level questions, and
   produces a retrospective report.

## State File (`~/.pomodoro/state.json`)

Written by the timer at every phase transition:

```json
{
  "phase":       "work | short_break | long_break | idle",
  "session":     2,
  "cycle":       1,
  "start_epoch": 1748000000,
  "end_epoch":   1748001500,
  "start_iso":   "2025-05-23T10:00:00Z",
  "end_iso":     "2025-05-23T10:25:00Z",
  "updated_iso": "2025-05-23T10:12:34Z"
}
```

## Supplementary State Files

| File                          | Purpose                                              |
|-------------------------------|------------------------------------------------------|
| `~/.pomodoro/state.json`      | Current timer phase, session, cycle, timestamps     |
| `~/.pomodoro/session.log`     | Append-only event log for the current cycle          |
| `~/.pomodoro/retro_done`      | Session number of the last completed retrospective   |
| `~/.pomodoro/timer.pid`       | PID of the background timer subprocess              |

## Scripts

| Script                    | Role                                                              |
|---------------------------|-------------------------------------------------------------------|
| `pomodoro.sh start`       | Start a new Pomodoro cycle (kills any existing timer)            |
| `pomodoro.sh status`      | Print `state.json` + human-readable time remaining              |
| `pomodoro.sh stop`        | Kill the background timer, reset state to `idle`                 |
| `pomodoro.sh log`         | Print the current cycle event log                                |
| `pomodoro-check.sh`       | Emit `RETRO_NEEDED <phase> <session> <cycle>` or `NO_ACTION`     |
| `pomodoro-mark-retro.sh`  | Write session number to `retro_done` (prevents repeat triggers)  |
| `pomodoro-context.sh`     | Dump full context (state + log + timestamp) for agent inspection |

## Resources

- `scripts/pomodoro.sh` — Timer engine
- `scripts/pomodoro-check.sh` — Loop-based phase detector
- `scripts/pomodoro-mark-retro.sh` — Retrospective completion marker
- `scripts/pomodoro-context.sh` — Full context snapshot for agent
- `agents/claude.md` — Claude agent behaviour specification
- `references/pomodoro-technique.md` — Technique background & rationale

## Quick Start

```bash
# 1. Start the timer (runs in background, writes to ~/.pomodoro/)
bash community/skills/pomodoro-timer/scripts/pomodoro.sh start

# 2. Start the detection loop (agent command)
# /loop 30s  →  see agents/claude.md for the exact loop prompt

# 3. Check phase manually at any time
bash community/skills/pomodoro-timer/scripts/pomodoro-check.sh

# 4. Mark retrospective complete after conducting it (session number required)
bash community/skills/pomodoro-timer/scripts/pomodoro-mark-retro.sh 2

# 5. Stop the timer
bash community/skills/pomodoro-timer/scripts/pomodoro.sh stop
```

## Environment Variables

| Variable                        | Default         | Description                            |
|---------------------------------|-----------------|----------------------------------------|
| `POMODORO_WORK_MIN`             | `25`            | Focus session duration (minutes)       |
| `POMODORO_SHORT_BREAK_MIN`      | `5`             | Short break duration (minutes)         |
| `POMODORO_LONG_BREAK_MIN`       | `30`            | Long break duration (minutes)          |
| `POMODORO_SESSIONS_BEFORE_LONG` | `4`             | Sessions per cycle before long break   |
| `POMODORO_STATE_DIR`            | `~/.pomodoro`   | Directory for all state files          |

## Design Decisions

### Why a polling loop instead of signals or callbacks?

Claude Code does not expose a persistent daemon or event listener. `/loop` is
the closest primitive to a background watcher: it fires the agent on a fixed
interval, keeps the conversation alive, and hands control back to the agent
which can then decide whether to act. A 30-second interval means the agent
responds within half a minute of a phase transition — well within the 5-minute
short-break window.

### Why `retro_done` instead of checking `phase` alone?

The break phase persists in `state.json` for its full duration (5 or 30 min).
Without a "done" marker, every loop tick during a break would re-trigger the
retrospective. `retro_done` stores the last retrospected session number; if the
current session matches, `pomodoro-check.sh` emits `NO_ACTION`.

### Why does the agent, not the user, initiate retrospectives?

Extended AI-assisted work sessions are cognitively demanding. By the time a
break starts, the user may be too fatigued to remember or bother requesting a
retrospective. The agent acting first removes that friction and enforces the
rest and reflection the technique is designed to provide.
