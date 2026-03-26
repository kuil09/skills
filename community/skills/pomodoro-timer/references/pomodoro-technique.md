# Pomodoro Technique — Reference

## Origin

The Pomodoro Technique was developed by Francesco Cirillo in the late 1980s.
He named it after the tomato-shaped kitchen timer he used as a student
("pomodoro" is Italian for tomato).

## Standard Cycle

| Phase         | Duration | Frequency per cycle          |
|---------------|----------|------------------------------|
| Focus session | 25 min   | 4 per cycle                  |
| Short break   | 5 min    | After sessions 1, 2, 3       |
| Long break    | 30 min   | After session 4 (end of cycle)|

## Core Principles

1. **Single-task focus** — Work on one thing only during a session. No
   multitasking.
2. **Protect the session** — Treat interruptions as deferred: note them down
   and return to them during a break.
3. **Complete rest** — Breaks are for recovery, not continued screen time.
   Stand up, hydrate, look away from the screen.
4. **Review and adapt** — Short retrospectives after each session surface
   patterns in how you work and where friction appears.

## Why It Works

- **Time-boxing reduces perfectionism.** Knowing there is a fixed end point
  makes it easier to start and maintain focus.
- **Forced breaks prevent cognitive fatigue.** Regular pauses restore attention
  and reduce error rates.
- **Retrospectives build self-awareness.** Naming blockers and intentions makes
  them actionable.

## Using Pomodoro with an AI Agent

Extended AI-assisted work sessions are especially taxing: the constant back-and-
forth of prompting, reviewing, and redirecting consumes significant cognitive
bandwidth. Key adaptations:

- **The agent acts first.** By the time a break arrives the user may be too
  fatigued to initiate reflection. The agent should detect the transition and
  intervene without being asked.
- **Retrospectives serve as context resets.** Summarising what was accomplished
  — and what comes next — helps both the user and the agent stay aligned on the
  session goal rather than drifting.
- **The long-break cycle retrospective is a defrag.** After 4 sessions the
  consolidated report captures what worked, what recurred as friction, and
  where to focus energy in the next cycle. This is especially valuable in long
  agentic work sessions where context can otherwise accumulate and become noisy.

## Adapting the Timings

The 25/5/30 defaults are a starting point, not a rule. Adjust via environment
variables (see `SKILL.md`) to suit your concentration style:

| Style              | Work | Short break | Long break |
|--------------------|------|-------------|------------|
| Standard           | 25   | 5           | 30         |
| Deep work          | 50   | 10          | 30         |
| Quick iterations   | 15   | 3           | 20         |
| Exploration mode   | 20   | 5           | 25         |
