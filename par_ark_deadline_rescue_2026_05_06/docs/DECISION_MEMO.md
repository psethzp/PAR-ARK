# Decision Memo — May 6/7 Deadline

## Are the current results enough?

Yes for an ICML workshop paper **only if the paper is reframed as a failure/diagnostic paper**. No for an A*/Core-A main-track positive SOTA claim.

Current evidence:

- Qwen3-14B validation grid: `off` is best on average across Hit@1, Hit@5, R@20, and MRR.
- Qwen3-30B-A3B pilot: `full` loses to `off` on every graph by MRR, Hit@5, and R@20.
- `full` is faster in the pilot but loses substantial accuracy, especially on MAG.
- The intervention creates useful telemetry: global searches, neighborhood searches, zero-result calls, and repeated calls.

Therefore the strongest workshop story is not “PAR-ARK is SOTA.” It is:

> Adaptive breadth-depth retrieval can become actively harmful for local/open-weight LLM agents. Final-score metrics reveal the drop, but trace metrics explain the mechanism: over-exploration, zero-result tool calls, repeated calls, and premature/faulty evidence commitment.

## Venue target

Primary: FAGEN / ICML 2026 Failure Modes in Agentic AI.

Why: The current results directly match reproducible failure trigger + trace diagnostics + verified fixes/trade-offs.

Secondary: FMSD / ICML 2026 Foundation Models for Structured Data, only if the paper is positioned around structured-data retrieval evaluation and not as a positive method result.

Do not use GFM as primary unless Stage E unexpectedly shows positive graph retrieval improvements.

## Required title and claim

Recommended title:

**When Adaptive Knowledge-Graph Retrieval Fails: Trace Diagnostics for Local LLM Agents on STaRK**

Main claim:

> On STaRK, adding profile/trace-conditioned adaptive retrieval to a local open-weight ARK-style agent can reduce rank quality despite reducing wall-clock time. Trace-level metrics show why the agent fails and provide reproducible triggers for future repair.

## Minimum acceptable evidence package

Already available:

1. Stage A: 24-cell Qwen3-14B validation grid, n≈100 per cell.
2. Stage B2: 6-cell Qwen3-30B-A3B test pilot, n≈50 per cell.

Need if time:

3. Stage E: Qwen3-30B-A3B test subset, n=200–300 per graph per mode for off/full.
4. Stage F: budget-fix probe, n=150 per graph, to show whether stricter budgets mitigate harm.
5. Pair diagnostics: paired wins/losses, oracle diagnostic upper bound, trace-condition deltas.

## What not to run

- Do not run full Stage C unchanged unless all writing is done and compute is otherwise idle.
- Do not run Stage D full reranking; it is not central and risks eating the deadline.
- Do not add new models.
- Do not tune on test labels.
