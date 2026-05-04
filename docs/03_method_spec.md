# PAR-ARK Method Specification

Working title: **PAR-ARK: Profile-Conditioned Trace-Aware Adaptive Retrieval for Text-Rich Knowledge Graphs**

## Base

Start from ARK, not AF-Retriever. ARK already does adaptive breadth-depth KG retrieval. We add what ARK lacks:

1. pre-retrieval profile/action conditioning;
2. trace-state evidence sufficiency;
3. repair hints after failed or wasteful graph actions;
4. local open-weight execution and optional local self-distillation.

## Major change 1: Profile-Conditioned Action Prior (PCAP)

Before the first graph action, construct a compact JSON profile from the query and optional user/profile text.

Example profile:

```json
{
  "target_entity_type": "paper",
  "must_cover_facets": ["graph retrieval", "personalization", "reasoning"],
  "soft_preferences": ["recent", "open-weight", "efficient"],
  "forbidden_or_low_priority": ["closed API dependency"],
  "relation_hints": ["authored_by", "cites", "has_topic"],
  "search_bias": "start broad, then traverse relation-specific neighborhoods"
}
```

On STaRK, no true user history exists by default, so this is a **query-profile**. If using PersonaBench/PBR, feed actual user history and call it personalization. Do not overclaim personalization from STaRK-only experiments.

Implementation:

- Add `par_profile.py` to extract profile facets deterministically or via the same local model.
- Add profile JSON to the user message before tool use.
- Bias tool use in prompt: if profile has many named entities, global search first; if relation hints exist, neighborhood search after anchors; if facet coverage is incomplete, re-anchor rather than finish.

## Major change 2: Trace-State Evidence Sufficiency and Repair (TESR)

After every tool call, record:

- tool name and arguments;
- result count;
- repeated query/node warnings;
- candidate explosion flags;
- zero-result flags;
- node type / edge type coverage when available;
- selected answer count;
- remaining budget.

Then append a short controller hint to the next model input:

- zero global search result → shorten query or search named anchor only;
- zero neighborhood result → relax node_type/edge_type or re-anchor globally;
- high result count → tighten by node type, edge type, or query facet;
- repeated call → do not repeat; switch action;
- enough plausible answers → finish.

This preserves ARK's tool interface while making the retrieval policy trace-aware.

## Minor changes

1. **Hard budget controller:** max global searches, max neighborhood searches, max steps, max observation chars.
2. **Sequential multi-agent aggregation:** run multiple trajectories sequentially to avoid vLLM OOM; aggregate by vote/first-seen as ARK does.
3. **Candidate cache/dedup:** identical tool calls return cached responses and trigger a no-repeat hint.
4. **Offline reranker stage:** stop controller vLLM; rerank candidates with Qwen3-Reranker-8B or bge-reranker-v2-m3.
5. **Optional local self-distillation:** use Qwen3-30B-A3B PAR-ARK trajectories as teacher data for Qwen3-8B LoRA.

## Required ablation table

| Variant | PCAP | TESR | Budget | Rerank | Distill | Expected purpose |
|---|---:|---:|---:|---:|---:|---|
| ARK-local | no | no | base | no | no | same-backbone baseline |
| PAR-ARK-profile | yes | no | yes | no | no | isolates profile/action prior |
| PAR-ARK-trace | no | yes | yes | no | no | isolates repair/sufficiency |
| PAR-ARK-full | yes | yes | yes | no | no | main method |
| PAR-ARK-full+rerank | yes | yes | yes | yes | no | optional quality boost |
| PAR-ARK-8B-distilled | yes | yes | yes | optional | yes | local efficient student |
