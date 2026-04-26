# Skills

A collection of reusable AI agent skills — structured frameworks that guide agents to reason and act more rigorously.

---

## Skills

### [`hypothesis-driven-task-execution`](./hypothesis-driven-task-execution/SKILL.md)

A scientific thinking framework that treats every piece of information — user requests, agent responses, feedback, and experiment results — as a hypothesis to be verified through falsification-first experimentation.

**When to use:** investigation, debugging, root cause analysis, validating assumptions, or any task involving uncertainty or competing explanations.

**Key concepts:**
- **5 Hypothesis Layers (L1–L5):** source-aware classification of every claim (user request → agent response → user feedback → experiment interpretation → external knowledge)
- **6-Phase Protocol:** Observe → Hypothesize → Predict → Experiment → Analyze → Conclude
- **Falsification-first:** attempt to disprove a hypothesis before seeking confirmation
- **Confidence scale:** speculation → low → medium → high (based on independent falsification attempts survived)
- **Safeguards:** hypothesis budget (max 5 active), iteration cap (max 5 primary loops), confirmation-bias guards

### [`git-notes-agent-memory`](./git-notes-agent-memory/SKILL.md)

Cross-session **agent memory** stored as Git notes: a **canonical** handoff note (`refs/notes/agent-memory`) plus optional **per-agent** notes (`refs/notes/am-agents/<id>`) with `./agent-memory.sh aggregate` for overlap heuristics (`wasteful_duplicate` / `healthy_parallel`). Ships **`agent-memory.sh`** (bash only) and **`SCHEMA.md`**.

**When to use:** session handoffs, multi-agent coordination, resuming after context loss, or parallel work where you want structured overlap detection without using raw Git merge conflicts as the primary signal.

**Key concepts:**
- **Two modes:** canonical cumulative note vs per-agent refs + aggregation (see `SCHEMA.md` Optional — Phase 3 fields: `task_id`, `hypothesis_hash`)
- **Refs:** `am-agents` is a **sibling** of `agent-memory` (Git cannot nest `agent-memory/agents/...` under the leaf ref `agent-memory`)
- **Experiments:** reproducible scenarios in the `agent-memory-lab` repo (`EXPERIMENT_PHASE2.md`, `EXPERIMENT_PHASE3.md`)

### [`api-goal-canvas-designer`](./api-goal-canvas-designer/SKILL.md)

Builds an **API Goal Canvas** (`Whos | Whats | Hows | Inputs | Outputs | Goals`) from rough API, product, or workflow descriptions. Each row is a coherent `Who → What → How → Input → Output → Goal` flow record, not a loose collection of cells. Detailed rules, heuristics, and templates live in [`references/REFERENCE.md`](./api-goal-canvas-designer/references/REFERENCE.md).

**When to use:** designing or reviewing APIs, restructuring feature-centric requirements into actor-goal flows, or detecting missing producers/consumers, orphan records, and over-segmented request flows.

**Key concepts:**
- **Six-column canvas:** request-level meaning over endpoint-level labels
- **Connectivity checks:** missing producer / missing consumer / orphan record detection
- **Decomposition rules:** break vague verbs (`manage`, `process`, `integrate`) into concrete actions; separate direct users from indirect consumers, internal services, external systems, operators, and batch actors
- **Tags:** `[confirmed]`, `[inferred]`, `[missing]`, `[orphan]`
- **Completion states:** `INCOMPLETE` → `DRAFT_COMPLETE` → `FINAL_COMPLETE`, paired with Discovery / Draft / Final response modes

---

## Using both skills together (synergy)

**Hypothesis-driven task execution** gives you *how* to run an investigation: explicit falsifiable claims, predictions, experiments, and a hypothesis ledger with confidence levels.

**Git notes agent memory** gives you *where* that state survives: durable notes on commits, readable by any bash-capable agent after a restart or handoff.

Together they support:

1. **Durable scientific runs** — Record the current hypothesis ledger, next falsification experiment, and open questions in a canonical note after each commit; the next session `read`s the same structure the hypothesis skill prescribes instead of starting from a blank slate.

2. **Multi-agent experiments** — Parallel agents write to `refs/notes/am-agents/<id>` with `task_id` and `hypothesis_hash` aligned to your hypothesis labels; `aggregate` surfaces **wasteful duplicate** work (same task + same hypothesis variant) vs **healthy parallel** exploration (same task + different hypothesis variants) — a concrete bridge between “rival hypotheses” in the framework and observable overlap in the repo.

3. **Evidence that outlives the chat** — Falsification outcomes and ledger updates can live in note bodies (`## Context`, decisions) so “what we tried and what survived” stays tied to the git timeline, not only to model context.

Load both skills when you are running **long-running or multi-session investigations** that should stay **structured** (hypothesis protocol) and **reproducible** (git-addressable memory).

---

## Usage

Each skill is defined in a `SKILL.md` file and can be referenced in agent system prompts, task instructions, or tool configurations. Skills are composable — apply full rigor for complex investigations, lighter application for mechanical tasks.
