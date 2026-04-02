---
name: hypothesis-driven-task-execution
description: >-
  A scientific thinking framework that treats every piece of information
  (user requests, agent responses, feedback, experiment interpretations) as
  a hypothesis to be verified through falsification-first experimentation.
  Use when asked to investigate, verify, debug, validate, test claims,
  test assumptions, analyze root causes, or when the task involves
  uncertainty, competing explanations, or non-obvious causality.
---

# Hypothesis-Driven Task Execution

A framework for treating all information exchange as hypotheses and
verifying them through scientific experimental design.

## Foundational Principle: Everything Is a Hypothesis

Nothing is ground truth. Every piece of information — regardless of its
source — is a hypothesis until supported by converging evidence that has
survived falsification attempts.

This principle applies to the framework itself. The claim that
"falsification-first is the best approach for this task" is an L2
hypothesis. If evidence suggests a different epistemology (e.g., Bayesian
updating, heuristic satisficing) would serve the current task better,
revise the approach. See Limitations below.

### Hypothesis Layers

| Layer | Source | Example |
|-------|--------|---------|
| L1 | User request | "This bug is a cache issue" -> H: cache is the root cause |
| L2 | Agent response | "Logs suggest a DB timeout" -> H: DB timeout is the cause |
| L3 | User feedback | "No, it's a network problem" -> H: network is the cause |
| L4 | Experiment interpretation | "Ping test passed -> network is fine" -> H: ping test is the right verification method for this problem |
| L5 | External knowledge | "Docs say this library has a known race condition" -> H: this known issue applies to our specific usage and version |

Confidence comes from **accumulated evidence**, not authority. A statement
is not true because the user said it, the agent concluded it, or a test
passed. Evidence **converges** when 2+ independent sources or methods
point to the same conclusion.

## When to Apply

**Apply this framework when:**
- The task involves causal reasoning ("why", "because", "root cause")
- Multiple explanations are plausible
- The user's request contains implicit assumptions worth verifying
- Investigation or debugging is needed
- Architectural or design decisions carry trade-offs
- Performance claims need validation

**Use proportional rigor (lighter application) when:**
- The request appears mechanical with low ambiguity (read a file, format
  code) — note: "appears mechanical" is itself a low-stakes hypothesis;
  verify briefly before skipping (e.g., confirm the file exists before
  reading, confirm the format spec before applying)
- The user requests minimal analysis — treat this as an L1 hypothesis
  about the appropriate level of rigor; comply but explicitly note that
  rigor was reduced and mark any conclusions as "speculation"
- The task is a simple lookup with a deterministic answer — still verify
  the answer source is authoritative rather than assumed

## The 6-Phase Protocol

### Phase 1: Observe

Collect the current state before forming any hypothesis.

- Read relevant code, logs, metrics, or documentation
- Note what is **actually observed** vs what is **claimed**
- Record the raw observations without interpretation

### Phase 2: Hypothesize

Extract testable hypotheses from **all inputs** — user requests, your own
reasoning, user feedback, and prior experiment results.

For each hypothesis, define:
1. **Statement**: A specific, falsifiable claim
2. **Falsification criteria**: What result would **disprove** this hypothesis
3. **Source layer**: L1 / L2 / L3 / L4 / L5

A hypothesis without falsification criteria is not a hypothesis. "Something
might be wrong" is not testable. "The cache returns stale data before TTL
expiry" is testable because you can define what observation would disprove it.

When possible, formulate **rival hypotheses** — multiple competing
explanations for the same observation. A failed prediction may refute the
hypothesis **or** an unstated auxiliary assumption (the Duhem-Quine
problem: no hypothesis is tested in isolation — it always relies on
background assumptions like "my test environment is correct"). State key
auxiliaries explicitly so a negative result is interpretable.

**Triage — when multiple hypotheses exist**, prioritize by:
1. **Falsifiability cost**: test the cheapest-to-disprove hypothesis first
   (e.g., checking a config file before profiling a distributed system)
2. **Impact if true**: prioritize hypotheses whose truth would have the
   largest consequence on the chosen action
3. **Differential power**: prefer experiments that can distinguish between
   multiple rival hypotheses simultaneously over those that test only one

If time is constrained, explicitly state which hypotheses were deferred
and why, so the user can decide whether to revisit them.

### Phase 3: Predict

For each hypothesis, state **bidirectional predictions**:

- **If true**: what specific, observable outcome should occur
- **If false**: what specific, observable outcome should occur instead

For rival hypotheses, identify **differential predictions** — outcomes that
would be true under one hypothesis but false under another. These are the
most valuable experiments to run because they eliminate competitors.

### Phase 4: Experiment

Design and execute the **minimum experiment** needed to test predictions.

**Falsification-first**: prioritize experiments that attempt to **disprove**
the hypothesis rather than confirm it. A hypothesis that survives a
genuine attempt to break it is stronger than one with only confirming
evidence.

Experiment design checklist (not all must be yes — document violations):
- [ ] Does this experiment test the falsification criteria?
- [ ] Is there a control (baseline for comparison)?
- [ ] Is only one variable changing at a time?
- [ ] Could the result of this experiment distinguish between rival hypotheses?
- [ ] Is the experiment the smallest possible test for the prediction?

### Phase 5: Analyze

Compare experiment results against predictions.

- Did the result match the "if true" or "if false" prediction?
- If the result matched **neither** prediction, the hypothesis or the
  experiment design has a gap — register both as L4 hypotheses
- Could the result be explained by something other than the hypothesis?
  (If yes, register that alternative explanation as a new L4 hypothesis)
- Did the experiment actually test what it intended to test?
  (If uncertain, register the validity of the experiment itself as an L4
  hypothesis)

**Self-check**: your interpretation of the results is also a hypothesis.
If the interpretation is non-obvious or consequential, register it at L4
and consider whether it warrants its own verification cycle.

### Phase 6: Conclude

Present conclusions with explicit confidence levels and supporting evidence.

Update the hypothesis status:
- **Falsified**: evidence contradicts the hypothesis -> discard or revise
- **Survived**: hypothesis withstood a falsification attempt -> confidence rises
- **Unresolved**: experiment was inconclusive -> redesign experiment or refine hypothesis
- **Deferred**: deprioritized per triage -> revisit if needed (see Hypothesis budget)

If falsified, return to Phase 2 (max 5 primary iterations per task —
see Safeguards). If survived, assess whether confidence is sufficient
to act or further falsification is warranted.

## Falsification-First Principle

Derived from Popper's falsificationism, applied to practical work:

### 1. Unfalsifiable claims are not hypotheses

Reject vague claims that cannot be disproven. Rewrite them into falsifiable
form before proceeding.

| Unfalsifiable (reject) | Falsifiable (accept) |
|------------------------|----------------------|
| "There might be a performance issue" | "P95 latency exceeds 200ms on the /search endpoint under 100 concurrent requests" |
| "The code quality is bad" | "Module X has cyclomatic complexity above 15 in 3+ functions" |
| "This approach is better" | "Approach A reduces memory allocation by 30% compared to approach B on the benchmark dataset" |

### 2. Falsification before confirmation

Instead of "let me verify this is correct," say "if this were wrong, I
would expect to see X — let me check for X."

Confirmation-seeking experiments are structurally prone to bias;
falsification-seeking experiments are structurally resistant to it.

### 3. Surviving falsification builds confidence

| Falsification attempts survived | Confidence level |
|--------------------------------|-----------------|
| 0 (untested or only confirmed) | speculation |
| 1 | low |
| 2 (independent methods) | medium |
| 3+ (independent methods) | high |

"High" is the ceiling — empirical hypotheses are never proven, only
increasingly hard to falsify. Two methods are **independent** when they test the hypothesis through
different mechanisms (e.g., log analysis vs. live reproduction) — not
merely repeating the same test. Prefer **severe** tests: ones with a
high chance of detecting the fault if it exists. A hypothesis with 5
confirming experiments but 0 falsification attempts remains at
"speculation." A hypothesis that survived 2 severe, independent attempts
to break it reaches "medium."

For **deductive or mathematical claims** (e.g., "this algorithm is O(n
log n)"), formal proof is possible and stands outside this empirical
confidence scale. Mark such claims as "formally proven" and note the
proof method separately.

### 4. Rival hypotheses and differential prediction

When multiple explanations exist for the same observation:

1. List all plausible hypotheses (H1, H2, H3...)
2. Find a prediction where H1 says "X happens" but H2 says "Y happens"
3. Design one experiment that tests this differential prediction
4. The result eliminates at least one competitor

This is more efficient than testing each hypothesis in isolation.

## Hypothesis Extraction Patterns

### From user requests (L1)

| Request pattern | Implicit hypothesis |
|----------------|-------------------|
| "Fix the bug in X" | H: there is a bug, and it is in X |
| "Refactor this for performance" | H: refactoring will improve performance; H: performance is currently insufficient |
| "Add feature X" | H: feature X is the right solution to the underlying need |
| "This is caused by Y" | H: Y is the cause |

### From your own responses (L2)

After generating any analysis or recommendation, ask:
- "What am I assuming that I haven't verified?"
- "If I'm wrong, what would I expect to see?"
- "Is there a simpler explanation I'm overlooking?"

### From user feedback (L3)

When the user corrects or redirects:
- **Directives** (scope, policy, "stop", preferences): comply first,
  then register as a new hypothesis if you want to verify the rationale
- **Empirical claims** ("the cause is X"): treat as a new hypothesis,
  not an authoritative override — verify with the same rigor
- If evidence conflicts with the user's feedback, present the evidence
  and let the user decide — do not silently defer to authority

### From experiment interpretation (L4)

After each experiment:
- "Did my experiment actually test what I think it tested?"
- "Could this result be an artifact of my test setup?"
- "Am I interpreting absence of evidence as evidence of absence?"

### From external knowledge (L5)

When consulting documentation, known-issue databases, CVEs, or prior
experience:
- The external source's claim is a hypothesis, not settled fact — verify
  it applies to this specific context (version, configuration, usage
  pattern)
- External sources carry higher prior plausibility than raw speculation
  but still require falsification: "this known bug matches our symptoms"
  must be tested, not assumed
- Cross-reference multiple independent external sources when possible

## Confidence Tracking

Maintain a hypothesis ledger throughout the task. Each entry tracks:

```
Hypothesis: [specific falsifiable statement]
Source: L1 / L2 / L3 / L4 / L5
Falsification criteria: [what would disprove this]
Status: falsified / survived / unresolved / deferred
Falsification attempts: [count — for each, note method and severity]
Confidence: speculation / low / medium / high / formally proven (deductive only)
Evidence: [list of experiment results, both supporting and opposing]
Conclusion: [action taken or recommended based on current status]
```

## Output Template

When reporting findings, use the same fields as the ledger. The output
template is the ledger rendered for the user:

```
## Hypothesis Status Report

### H1: [statement]
- Source: [L1/L2/L3/L4/L5]
- Falsification criteria: [what would disprove this]
- Status: [falsified / survived / unresolved / deferred]
- Falsification attempts: [count]
  - [experiment description] -> [method, severity] -> [result] -> [survived/falsified]
- Confidence: [speculation / low / medium / high / formally proven]
- Evidence: [key supporting and opposing evidence]
- Conclusion: [action taken or recommended]

### H2: [statement]
...

## Evidence Summary
- Converging evidence supports: [which hypotheses]
- Falsified and discarded: [which hypotheses]
- Remaining uncertainty: [what is still unresolved]

## Action Taken
[What was done based on the surviving hypotheses and their confidence levels]
```

For complex investigations, use the full template. For simple tasks, an
inline summary may omit fields but must include Statement, Status,
Confidence, and Conclusion.

## Worked Example: Bug Investigation

User says: "The /orders API is returning stale data. It's a cache issue."

### Phase 1: Observe
- Read the /orders endpoint handler and caching layer code
- Check recent deployments and config changes
- Observe: the endpoint uses Redis cache with 300s TTL

### Phase 2: Hypothesize
- **H1** (L1, from user): Redis cache returns stale data before TTL expiry
  - Falsification criteria: if bypassing Redis and querying the DB directly
    returns the same stale data, the cache is not the differentiating
    factor and H1 is falsified
- **H2** (L2, rival): the application reads from a DB replica (which may
  lag behind the primary)
  - Falsification criteria: if the application's read path uses the
    primary (not a replica), H2 is falsified
  - Note: H2 surviving only confirms a replica is used; **lag** requires
    a separate measurement (see iteration 2 next step)
- Triage: H1 is cheaper to test (bypass cache = one query), and the
  differential prediction can resolve both simultaneously. Test H1 first.

### Phase 3: Predict
- H1 if true: reading from Redis after a write returns old data; bypassing
  Redis returns fresh data
- H1 if false: Redis returns the same data as a direct DB query
- H2 if true: querying through the app's read path (replica) returns stale
  data; querying the primary directly returns fresh data
- H2 if false: the app's read path already uses the primary, so stale data
  must have another cause
- Differential prediction: if bypassing cache and querying the primary
  directly returns fresh data, H1 is supported; if it still returns stale
  data, both H1 and H2 need re-examination

### Phase 4: Experiment (falsification-first)
- Design: query the primary DB directly after a known write, bypassing
  both Redis and the application's read path. This attempts to falsify H1
  by removing the cache variable.
- Checklist: tests H1 falsification criteria? yes. Control? comparison
  is the cached response. Single variable? no (cache and read path both
  bypassed — accepted as a coarse first pass). Distinguishes rivals?
  partially. Smallest test? yes (one query).
- Result: direct primary DB query returns **fresh data**

### Phase 5: Analyze
- The "if true" prediction for H1 matched: bypassing Redis returns fresh
  data while the cached response was stale. H1 **survived**.
- H2 is not yet tested — we bypassed both cache and the app's read path.
  Need to check whether the app normally reads from a replica.
- L4 hypothesis registered: "the direct query tool used the same
  connection path as the application" — verify by comparing connection
  strings

### Phase 6: Conclude (iteration 1)

H1 survived one falsification attempt (confidence: low). H2 untested.
Continue with H2.

**Iteration 2 — Phase 2 (refined)**:
- H1 survives, confidence: low
- H2 untested -> design experiment to falsify H2
- **H2-L4** (L4): the application's read connection string points to a
  replica, not the primary
  - Falsification criteria: if the read connection string points to the
    primary, H2 is falsified

**Iteration 2 — Phase 4**:
- Experiment: inspect the application's read connection string in config
- Result: read connection string points to
  `orders-db-replica.internal:5432` (a replica)
  -> H2-L4 survived, and H2 itself survived (the app does read from a
  replica)

**Iteration 2 — Phase 5**:
- H2 survived: the app reads from a replica, which could explain stale
  data. Combined with H1 surviving (cache bypass + primary = fresh data),
  evidence converges: both cache staleness and replica lag may contribute.
- Revised understanding: the cache serves stale data because it was
  populated from the replica, which lags behind the primary.

**Iteration 2 — Phase 6**:

```
## Hypothesis Status Report

### H1: Redis cache returns stale data before TTL expiry
- Source: L1 (user)
- Falsification criteria: bypassing cache returns fresh data
- Status: survived
- Falsification attempts: 1
  - Direct primary DB query after write -> fresh data returned -> survived
- Confidence: low
- Evidence: primary DB returns fresh data; cached response returns stale
- Conclusion: cache is serving stale data; root cause is what populates it

### H2: Application reads from a DB replica
- Source: L2 (agent)
- Falsification criteria: app read path uses primary
- Status: survived
- Falsification attempts: 1
  - Read connection string -> points to replica -> survived
- Confidence: low
- Evidence: config shows read path targets replica host
- Conclusion: replica lag feeds stale data into cache; investigate
  replication delay and cache invalidation strategy

### H1-L4: Direct query tool used the same connection path as the app
- Status: deferred (low impact given H2 confirmed replica path)

## Evidence Summary
- Converging on "replica is the stale data source": two independent
  methods (cache bypass + config inspection) reach the same conclusion
- Falsified: none

## Action Taken
Cache invalidation switched to write-through from primary; monitoring
replica lag. Next step: measure actual lag to confirm it exceeds TTL.
```

## Safeguards

### Preventing infinite loops

Two caps apply:
- **Primary loop**: max 5 Phase 2-6 iterations per task (see Phase 6)
- **Meta-verification**: max 3 cycles per hypothesis chain (a chain is
  H → H-L4 → H-L4-L4; a cycle is one Phase 2-6 pass from an L4)
- **Confidence threshold**: stop when "high" (3+ survived)
- **Diminishing returns**: stop if a cycle does not change confidence
- **Exit strategy**: report surviving hypotheses with current confidence,
  flag unverified claims, recommend the best-supported hypothesis, and
  suggest the next experiment if the user wants to continue

### Hypothesis budget

Limit active (status: `survived` or `unresolved`) hypotheses to **5 at
a time**. When the budget is full:

1. Falsify or defer an existing hypothesis before adding a new one
   (L1 hypotheses require user acknowledgment before deferral)
2. If none can be quickly falsified, defer the lowest-priority hypothesis
   (per triage criteria, subject to Rule 1) and note as "deferred"
3. Revisit deferred hypotheses only if no `survived` or `unresolved`
   hypotheses remain and the problem is unsolved

### Guarding against confirmation bias

- Always attempt falsification before seeking confirmation
- When evidence confirms your hypothesis, actively ask: "what else could
  explain this result?"
- When rival hypotheses exist, do not abandon them just because one
  hypothesis gained early support — test the differential prediction
- Never treat "I couldn't disprove it" as "it's proven." Absence of
  disconfirming evidence is weaker than presence of confirming evidence,
  which is weaker than survival of falsification attempts

### Pragmatic escape

Not every statement needs full scientific rigor (see "When to Apply" for
entry criteria). Apply proportional skepticism:

- **Trivial claims** (file exists, syntax is valid): verify once, move on
- **Consequential claims** (root cause, architecture choice): full protocol
- **Time-sensitive situations**: note reduced rigor and mark confidence
  as "speculation" or "low"

## Limitations

This framework is itself a hypothesis about how to handle uncertainty in
software tasks. It has known boundaries:

- **Creative tasks**: defer falsification until after a generative phase
- **Time-critical emergencies**: act on the highest-confidence hypothesis
  available, even at "speculation"; note reduced rigor
- **Prior probability**: the confidence scale ignores priors — an
  implausible hypothesis surviving one test may not deserve "low";
  adjust with judgment and note when you do
- **Alternative epistemologies**: Bayesian reasoning, Lakatos, and
  pragmatism offer complementary lenses. If this framework hinders more
  than it helps, treat that as evidence and adapt
