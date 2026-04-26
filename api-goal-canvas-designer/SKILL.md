---
name: api-goal-canvas-designer
description: Builds an API Goal Canvas from rough API, product, or workflow descriptions. Use when designing or reviewing APIs, restructuring requirements around actors, tasks, inputs, outputs, and goals, or detecting missing links, orphan records, and over-segmented request flows.
metadata:
  author: openai-chatgpt
  version: "1.0.0"
  language: "en"
---

# API Goal Canvas Designer

Build an API Goal Canvas from incomplete API, product, or workflow descriptions.

Use this skill when:
- designing a new API
- reviewing or redefining an existing API
- converting feature-centric requirements into actor-goal flows
- finding missing producers, consumers, or intermediate steps
- collapsing over-segmented implementation fragments into request-level records

## Output

Produce a canvas with these columns in this exact order:

| Whos | Whats | Hows | Inputs (source) | Outputs (usage) | Goals |
|---|---|---|---|---|---|

Each row is a **record** and must represent a coherent flow unit, not a loose collection of cells.

## Core Record Rule

Every important record must read as:

`Who -> What -> How -> Input -> Output -> Goal`

If any connection is missing, treat that as missing structure, not acceptable sparsity.

## Working Method

Always reason in this order:

1. Whos
2. Whats
3. Hows
4. Inputs
5. Outputs
6. Goals
7. Connectivity
8. Consolidation
9. Completion state

## Required Behaviors

### 1. Build request-level meaning, not endpoint-level labels
Do not restate endpoint names as goals.

### 2. Decompose vague verbs
Break vague verbs into concrete actions.

Examples:
- manage -> view / create / update / approve / audit
- process -> validate / transform / aggregate / route / store / notify
- integrate -> fetch / map / publish / sync / hand off

### 3. Separate actors properly
Distinguish:
- direct users
- indirect consumers
- internal services
- external systems
- operators or reviewers
- scheduled or batch actors

### 4. Infer from inputs and outputs
Use inputs and outputs to infer missing actors, tasks, methods, producers, consumers, or boundaries.

### 5. Detect missing connections
If an output exists without a downstream consumer, mark a missing consumer.
If an input exists without an upstream producer, mark a missing producer.
If a record does not connect to any relevant neighboring flow, mark it as orphaned.

### 6. Detect over-segmentation
If consecutive records share the same request boundary, same input source, and same output usage, treat them as merge candidates.
Move implementation details into `Hows` unless they represent an independent boundary.

## Tags

Use these tags when needed:
- `[confirmed]`
- `[inferred]`
- `[missing]`
- `[orphan]`

## Completion States

Mark the result as one of:

- `INCOMPLETE`
- `DRAFT_COMPLETE`
- `FINAL_COMPLETE`

### INCOMPLETE
Use when:
- a main flow is missing one of the six columns
- an important record does not form a coherent chain
- the goal is still just a feature or endpoint restatement
- important records are disconnected
- the structure is distorted by over-segmentation

### DRAFT_COMPLETE
Use when:
- main flows have all six columns
- the overall structure is usable
- some important items remain `[inferred]` or `[missing]`
- some record boundaries are still provisional

### FINAL_COMPLETE
Use when:
- the main actors, tasks, methods, input sources, output usages, and goals are coherent and stable
- important records are connected
- producer-consumer relationships are explainable
- no relevant record is orphaned
- unnecessary fragmentation has been removed

## Response Modes

### Discovery Mode
Use when information is incomplete.

Output:
- status
- draft canvas
- missing information
- connection gaps / orphan records / merge candidates
- up to 7 prioritized questions

### Draft Mode
Use when the main structure exists but uncertainty remains.

Output:
- status
- canvas
- reformulated goals
- connection gaps / orphan records / merge candidates
- uncertainty list

### Final Mode
Use when the structure is stable.

Output:
- status
- canvas
- key flow summary
- reformulated goals
- merge/split judgments
- risks and design implications

## Validation Checklist

Before finishing, check:

1. Does each record form `Who -> What -> How -> Input -> Output -> Goal`?
2. Does each important output have a consumer?
3. Does each important input have a producer?
4. Are there any orphan records?
5. Are there any records that should be merged because they are only internal steps of one request?
6. Are goals expressed as state change, operational outcome, or decision capability?

See [the reference guide](references/REFERENCE.md) for detailed rules, heuristics, examples, and templates.
