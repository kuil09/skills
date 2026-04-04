---
name: git-notes-agent-memory
description: >-
  Git notes agent memory: canonical ref refs/notes/agent-memory for handoff;
  optional per-agent refs refs/notes/am-agents/<id> with aggregate for overlap signals.
---

# Git Notes Agent Memory

## Two modes

**1) Canonical handoff (default)** — Single cumulative note on `refs/notes/agent-memory` at `HEAD`. Session start: `./agent-memory.sh read`. After every commit: `write` or `write-message`. One `next`; append-only `decisions`. **Last writer wins** if two agents share only this ref.

**2) Parallel agents + overlap detection** — Each agent writes its own note with `./agent-memory.sh write-agent <id>` (stdin) or `write-agent-message <id> <text>`. Notes live under **`refs/notes/am-agents/<id>`** (a **sibling** of the canonical ref; you cannot nest `.../agent-memory/agents/...` in Git because `refs/notes/agent-memory` is already a ref). Put `task_id` and `hypothesis_hash` on their own lines in YAML (see `SCHEMA.md`, Optional — Phase 3). Coordinator runs **`./agent-memory.sh aggregate`** on `HEAD` to print `wasteful_duplicate` vs `healthy_parallel` heuristics. Use `read-agent <id>`, `list-agents`.

**Common:** `./agent-memory.sh init` once. **No** raw `git notes` without the correct `--ref`. **Commit before write** on the ref you intend. **Push** notes explicitly: `git push origin refs/notes/agent-memory` and `git push origin 'refs/notes/am-agents/*'` (see `init` output).

Full fields, examples, and aggregation rules: **`SCHEMA.md`**. Reproducible scenarios: `agent-memory-lab` repo (`EXPERIMENT_PHASE2.md`, `EXPERIMENT_PHASE3.md`).
