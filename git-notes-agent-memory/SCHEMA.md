# Agent Memory Note Schema

Notes are stored in `refs/notes/agent-memory` and attached to commit SHAs.
Each note is a **cumulative summary** — HEAD's note always reflects the full current context.

---

## Format

```
---
<YAML frontmatter>
---

<Markdown body>
```

---

## YAML Frontmatter Fields

### Required

| Field | Type | Description |
|-------|------|-------------|
| `session` | ISO 8601 string | Timestamp when this note was last written |
| `agent` | string | Agent identifier (model name, tool name, or free string) |
| `commit` | string | Short SHA of the commit this note is attached to |
| `task` | string | Current primary task (one sentence) |
| `status` | enum | `pending` / `in_progress` / `done` / `blocked` |
| `next` | string | The single next action to take |

### Recommended

| Field | Type | Description |
|-------|------|-------------|
| `decisions` | list of strings | All key decisions made so far — **never delete, only append** |
| `open` | list of strings | Unresolved questions or blockers |

### Tools Context

| Field | Type | Description |
|-------|------|-------------|
| `tools.skills` | list of strings | Active skill names loaded this session |
| `tools.mcp` | list of strings | MCP servers in use |
| `tools.tokens.used` | integer | Estimated tokens consumed this session |
| `tools.tokens.limit` | integer | Model context window size |
| `tools.tokens.pressure` | enum | `low` / `medium` / `high` (used/limit ratio) |
| `tools.model` | string | Model identifier |
| `tools.platform` | string | `claude-code` / `codex` / `gemini-cli` / `cursor` / etc. |

### Optional — per-agent coordination (Phase 3)

Use these when multiple agents write to **separate** note refs (`refs/notes/am-agents/<agent_id>`). This namespace is a **sibling** of `refs/notes/agent-memory` (the canonical ref cannot have sub-paths in Git). Coordinators run **`aggregate`** without Git merge conflicts. Put each field on its **own line** in the frontmatter (simple `key: value` — required for the bundled `aggregate` command).

| Field | Type | Description |
|-------|------|-------------|
| `task_id` | string | Stable id for the unit of work (e.g. `bugfix-cache-race`) |
| `hypothesis_hash` | string | Short label or hash for the active hypothesis / experiment variant (e.g. `h-9f31`) |
| `work.target.commit` | string | Optional short SHA the work is pinned to |
| `work.target.files` | list of strings | Optional paths under investigation |

**Aggregation rules (coordinator / `./agent-memory.sh aggregate`):**

- Collect all agent notes on the **same commit** (`HEAD`) from `refs/notes/am-agents/*`.
- **Same `task_id` + same `hypothesis_hash`** on **two or more agents** → `wasteful_duplicate` (likely redundant effort).
- **Same `task_id` + different `hypothesis_hash`** across agents → `healthy_parallel` (exploring variants in parallel).
- **Same `work.target.files` overlap** with contradictory `status` or narrative (manual review) → possible `risky_conflict` — not inferred automatically in the shell prototype; document in Context instead.

The canonical **handoff** note on `refs/notes/agent-memory` remains the default; per-agent refs are for **parallelism + overlap detection**, not a replacement for cumulative HEAD context unless you merge explicitly.

---

## Markdown Body Sections

### `## Context` (required)
Free-form narrative. Describe the background, why this work is happening,
hypotheses in play, and any experimental results. Must be sufficient for
a new agent to reconstruct working context without prior conversation.

### `## Decisions Log` (recommended)
Prose explanation of the decisions listed in YAML. Include the reasoning,
not just the outcome.

### `## Blockers / Risks` (optional)
Current blockers or risks worth flagging to the next agent.

---

## Rules

1. **`decisions` is append-only.** Never remove a past decision. New agents add to the list.
2. **`next` is singular.** One action only. If you have multiple, pick the highest priority.
3. **Canonical `refs/notes/agent-memory` HEAD note is the handoff source of truth.** Per-agent refs under `refs/notes/am-agents/<id>` are for parallel work and aggregation; merge into canonical when you need a single successor context.
4. **Cumulative, not delta.** Each note fully replaces the previous — write the complete current state.

---

## Full Example

```
---
session: "2026-04-04T10:23:00Z"
agent: "claude-sonnet-4-6"
commit: "a3f9c21"

task: "Implement git-notes-agent-memory skill"
status: "in_progress"
next: "Write SKILL.md after SCHEMA.md is complete"

decisions:
  - "Use thin shell script approach for portability (not raw git commands)"
  - "Use refs/notes/agent-memory namespace to avoid default notes collision"
  - "HEAD note is cumulative summary — read O(1), write merges prior context"
  - "YAML frontmatter + Markdown body for machine + human readability"
  - "Include tools context (skills, mcp, tokens) for full reproducibility"

open:
  - "Concurrent commit conflict strategy for true multi-agent parallelism"

tools:
  skills:
    - "hypothesis-driven-task-execution"
    - "superpowers:brainstorming"
    - "superpowers:writing-skills"
  mcp: []
  tokens:
    used: 48000
    limit: 200000
    pressure: "low"
  model: "claude-sonnet-4-6"
  platform: "claude-code"
---

## Context

Building a universal agent skill that uses git notes to share memory
across sessions and between different AI agents (Claude, Codex, Gemini, etc.).

Design was driven by hypothesis-driven-task-execution framework.
Key constraint: must work with bash + git only, no external deps.

Brainstorming confirmed: commit-based addressing survives hard resets.
Thin script chosen over raw git commands to standardize the interface.

## Decisions Log

**Thin script over raw commands:** Agents using raw `git notes` would each
invent their own format. The script enforces the schema and namespace.

**refs/notes/agent-memory namespace:** Default `refs/notes/commits` is used
by other tools. Dedicated namespace prevents collisions and makes it easy
to fetch/push just agent memory.

**Cumulative HEAD note:** Reading N commits to reconstruct history is slow
and error-prone. HEAD note always has the full picture — simpler for agents.

## Blockers / Risks

- Concurrent writes on the **single** canonical ref overwrite each other (last writer wins).
  Mitigation: serialize, or use per-agent refs + `./agent-memory.sh aggregate` (see Optional — Phase 3 above).
```
