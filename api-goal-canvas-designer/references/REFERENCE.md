# API Goal Canvas Designer Reference

## Purpose

This reference defines the detailed operating model for building an API Goal Canvas.

The canvas is not a feature checklist. It is a structured flow model that answers:

- Who participates in the flow
- What each actor is trying to accomplish
- How each task is carried out
- What inputs are required and where they come from
- What outputs are produced and how they are used
- What state change, operational outcome, or decision capability the API ultimately enables

---

## Canonical Canvas Schema

Always use this column order:

| Whos | Whats | Hows | Inputs (source) | Outputs (usage) | Goals |
|---|---|---|---|---|---|

### Column Definitions

#### Whos
Actors involved in the flow:
- end users
- internal operators
- administrators
- internal services
- partner systems
- downstream systems
- scheduled jobs
- reviewers

#### Whats
What each actor is trying to accomplish.

Use task-level intention, not generic CRUD language unless CRUD is the actual business intent.

#### Hows
How the task is performed:
- workflow steps
- validation rules
- transformation logic
- orchestration
- approval paths
- execution mode
- retry / fallback behavior

#### Inputs (source)
What is required for the task:
- request fields
- permissions
- identities
- upstream state
- partner data
- derived context
- triggers

Always include the source.

#### Outputs (usage)
What is produced and how it is used:
- UI response
- stored state
- event publication
- operator view
- downstream automation
- audit evidence
- decision support

Always include the usage or consumer.

#### Goals
The real purpose of the flow.

Goals must be written as:
- state change
- decision capability
- operational outcome
- coordination outcome

Goals must not merely restate endpoint names or CRUD behavior.

---

## Core Record Model

A record is the minimum meaningful flow unit.

Every important record must form this chain:

`Who -> What -> How -> Input -> Output -> Goal`

A row that contains values but does not form this chain is still incomplete.

---

## Detailed Operating Procedure

### Step 1. Identify Whos

Find all direct and indirect actors.

Prompts:
- Who initiates the request?
- Who consumes the result?
- Which internal systems participate?
- Are there operators, reviewers, or scheduled jobs?
- Is there a downstream system that depends on the output?

### Step 2. Identify Whats

Describe each actor’s intention.

Prompts:
- What is this actor actually trying to get done?
- What business or operational action becomes possible?
- What is the real task beneath the surface request?

### Step 3. Identify Hows

Describe the mechanism, not just the existence of a function.

Prompts:
- What sequence or rule set performs this task?
- Is there validation, transformation, routing, approval, retry, or fallback?
- Is the execution synchronous, asynchronous, batch-based, or event-driven?

### Step 4. Identify Inputs

List required inputs and their sources.

Prompts:
- What data, state, permission, or context is required?
- Which source produces or supplies that input?
- What breaks if this input is absent?

### Step 5. Identify Outputs

List results and usage.

Prompts:
- What is produced directly?
- Who uses it?
- Is it for UI rendering, storage, notification, logging, downstream processing, or operator action?

### Step 6. Reformulate Goals

Rewrite the purpose in outcome terms.

Prompts:
- What does this API make possible?
- What decision or action becomes possible because of the output?
- What state change defines success?

### Step 7. Validate Connectivity

Check record-level and inter-record structure.

### Step 8. Validate Consolidation

Check whether records are over-fragmented and should be merged.

### Step 9. Assign Completion State

Choose the appropriate completion status.

---

## Connectivity Rules

The canvas is a network, not a filled spreadsheet.

### Record-Level Connectivity

For each important record, verify:

1. **Who -> What**
   - The actor must plausibly own or drive the task.

2. **What -> How**
   - The task must be grounded in an execution method.

3. **How -> Input**
   - The method must depend on identifiable inputs.

4. **Input -> Output**
   - The inputs must produce a meaningful output.

5. **Output -> Goal**
   - The output must support the stated outcome.

If any of these are absent or weak, the record has a missing connection.

### Inter-Record Connectivity

Also verify cross-record flow.

A gap exists when:

- an output has no downstream consumer record
- an input comes from an internal source but no upstream producer record exists
- a goal exists but no supporting flow produces the needed output
- a record connects to nothing relevant around it

### Missing Connection Heuristics

When a link is missing, first suspect:

- missing actor
- missing task
- missing method
- missing intermediate state transition
- missing system boundary

### Orphan Rule

Mark a record `[orphan]` if it does not connect to any relevant adjacent flow and cannot justify its presence as an independent boundary.

---

## Consolidation Rules

The canvas must avoid both missing structure and unnecessary fragmentation.

### Merge Candidate Conditions

Treat consecutive records as merge candidates when most of the following are true:

1. They belong to the same request boundary.
2. They share the same input source.
3. They share the same output usage.
4. They do not have independent producers or consumers.
5. They do not justify separate goals.
6. Their separation reflects implementation details rather than meaningful boundaries.

### Typical Fragments That Usually Belong Inside `Hows`

These are usually not standalone records unless they cross an independent boundary:

- input validation
- schema mapping
- DTO conversion
- cache lookup
- repository lookup
- response formatting
- lightweight normalization
- internal field enrichment

### Do Not Merge When

Keep records separate if they differ meaningfully in:

- actor boundary
- input contract
- output usage
- goal
- observable interface boundary

### Observable Interface Boundary Examples

These often justify independent records:

- incoming HTTP request
- webhook emission
- event publication consumed elsewhere
- manual review handoff
- scheduled batch trigger
- explicit approval gate
- partner API callback

---

## Goal Writing Rules

### Bad Goal Patterns

Do not write goals like:

- provide order lookup API
- support user management
- process payment data
- integrate with external service

These are feature or implementation restatements.

### Good Goal Patterns

Write goals as outcomes such as:

- Enable customers and operators to reference the same trustworthy order state so they can decide on cancellation, refund, or shipping actions.
- Allow fraud analysts to review high-risk transactions using normalized evidence and escalation signals.
- Let downstream fulfillment systems act on validated inventory commitments rather than raw request data.

### Goal Quality Test

A good goal answers at least one of these:

- What state changes?
- What decision becomes possible?
- What operational action becomes safer, faster, or more reliable?
- Who benefits from the resulting output and how?

---

## Inference Rules

Use cautious inference where structure clearly implies missing elements.

### Input/Output Inference

- If an input source is a partner system, add a partner actor candidate.
- If an output usage mentions a dashboard, add an operator or analyst actor candidate.
- If an output feeds automation, add an event, workflow, or downstream service candidate.

### Human/System Separation

Do not collapse all consumers into “user” or all producers into “system.”

Separate:
- human initiator
- system processor
- downstream consumer
- operator or reviewer

### Boundary Inference

When sources or consumers imply separate systems, check for:

- internal service boundaries
- event bus boundaries
- queue boundaries
- database state boundaries
- human intervention boundaries

---

## Completion States

### INCOMPLETE

Use when any of the following apply:

- one of the six columns is missing for a main flow
- an important record does not form a coherent chain
- key producer/consumer relationships are missing
- the goal is still a feature restatement
- major records are disconnected
- over-segmentation prevents meaningful interpretation

### DRAFT_COMPLETE

Use when:

- all six columns are populated for the main flows
- the structure is useful and mostly coherent
- some items remain `[inferred]` or `[missing]`
- some connectivity or boundary decisions remain provisional

### FINAL_COMPLETE

Use when:

- actors, tasks, methods, inputs, outputs, and goals are stable
- important records are connected
- producer-consumer relationships are explainable
- there are no relevant orphan records
- unnecessary fragmentation has been removed
- record boundaries are justified by actor, contract, usage, or goal differences

---

## Iteration Conditions

Refine the canvas when any of the following are true.

### Column Gap
- Whos exists but Whats is weak or absent
- Whats exists but Hows is weak or absent
- Inputs exist without source
- Outputs exist without usage
- Goals are only feature restatements

### Consistency Failure
- the actor does not plausibly own the task
- the method does not explain the task
- the input does not support the method
- the output does not support the stated usage
- the goal does not follow from the output

### Hidden Actor
- a source or consumer is implied but not represented as an actor where needed

### Connectivity Gap
- missing producer
- missing consumer
- unsupported goal
- orphan record

### Over-Segmentation
- consecutive records are really one request pipeline
- internal implementation fragments are presented as independent records
- multiple records share the same actor, same goal, and same consumer without an independent boundary

---

## Stop Rules

Stop asking questions when:

1. each additional question yields little structural improvement
2. the remaining uncertainty does not materially change the main goal interpretation
3. a useful draft can already be produced

Discovery mode should ask no more than 7 prioritized questions.

---

## Output Templates

### Discovery Mode

```markdown
## Status
INCOMPLETE

## API Goal Canvas

| Whos | Whats | Hows | Inputs (source) | Outputs (usage) | Goals |
|---|---|---|---|---|---|
| ... | ... | ... | ... | ... | ... |

## Missing Information
- ...

## Connection Gaps / Orphans / Merge Candidates
- ...

## Prioritized Questions
1. ...
2. ...
3. ...
```

### Draft Mode

```markdown
## Status
DRAFT_COMPLETE

## API Goal Canvas

| Whos | Whats | Hows | Inputs (source) | Outputs (usage) | Goals |
|---|---|---|---|---|---|
| ... | ... | ... | ... | ... | ... |

## Reformulated Goals
- ...

## Connection Gaps / Orphans / Merge Candidates
- ...

## Uncertainty
- ...
```

### Final Mode

```markdown
## Status
FINAL_COMPLETE

## API Goal Canvas

| Whos | Whats | Hows | Inputs (source) | Outputs (usage) | Goals |
|---|---|---|---|---|---|
| ... | ... | ... | ... | ... | ... |

## Key Flow Summary
- ...

## Reformulated Goals
- ...

## Merge / Split Judgments
- ...

## Risks and Design Implications
- ...
```

---

## Worked Example

### Input

- A customer wants to view order details.
- The system validates the order ID and reads from the order store.
- The result is shown in the customer UI.
- Operators also use the normalized order state in a dashboard.

### Output

| Whos | Whats | Hows | Inputs (source) | Outputs (usage) | Goals |
|---|---|---|---|---|---|
| Customer app [confirmed] | View order details [confirmed] | Call order lookup API [confirmed] | Order ID (client request) [confirmed], auth context (auth service) [inferred] | Order details response (customer UI) [confirmed] | Enable customers to confirm current order state before taking the next action [inferred] |
| Order query service [inferred] | Provide trustworthy order state [inferred] | Validate ID -> read store -> normalize response [inferred] | Order ID (client request) [confirmed], order data (order store) [inferred] | Normalized order state (UI rendering, operator reference) [inferred] | Ensure customer UI and operator tools rely on the same current order representation [inferred] |
| Operator [inferred] | Respond to problem orders [inferred] | Review dashboard state [inferred] | Normalized order state (order query service output) [inferred] | Response decision support (manual action) [inferred] | Enable quick cancellation, refund, or shipping decisions using shared order state [inferred] |

---

## Common Failure Patterns

Watch for these failure modes:

- all actors collapsed into “user”
- goals written as endpoint labels
- inputs and outputs listed as raw nouns without source or usage
- records that do not connect to neighboring flow
- implementation fragments split into too many rows
- outputs without consumers
- inputs without producers
- goals unsupported by any real input-output chain
