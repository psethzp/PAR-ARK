# Human Summary — What to Do From Here

## Main answer

There is no guaranteed A*/Core-A main-track acceptance in 2–3 days, especially without GPT/API. The strongest realistic plan is:

- Build on ARK, because it is the latest adaptive KG retrieval baseline on STaRK.
- Run only open-weight local models.
- Compare against same-backbone ARK-local, not only GPT-ARK.
- Cite GPT-ARK as a published upper bound.
- Submit a workshop paper first; extend to main track after stronger results.

## Best local model setup

- **Development:** Qwen3-8B on one L40.
- **Main ablations:** Qwen3-14B on one L40.
- **Final quality:** Qwen3-30B-A3B-Instruct-2507 on two L40 with tensor parallelism.
- **Optional rerank:** Qwen3-Reranker-8B after stopping controller vLLM.
- **Optional distill:** self-distill Qwen3-8B from Qwen3-30B-A3B PAR-ARK trajectories.

## Why this can be accepted

The paper is not just “we used a smaller model.” It has two real changes:

1. Profile-conditioned action prior: query/user profile affects retrieval actions before search.
2. Trace-state repair: failed graph actions produce structured repair hints and budget-aware control.

And four engineering/analysis additions:

- no-GPT local reproducibility;
- sequential multi-agent aggregation without OOM;
- offline reranker stage;
- failure taxonomy and budget table.

## What would get rejected

- Claiming guaranteed main-track acceptance.
- Claiming SOTA over ARK/GPT without beating it.
- Claiming personalization using only STaRK query text.
- Loading multiple models together and crashing/OOM.
- Reporting only one table without ablations and budget analysis.

## Best submission decision

- Positive STaRK results: ICML Graph Foundation Models workshop.
- Mixed results but good failure traces: ICML failure/diagnostics workshop.
- Strong personalization side experiment: KDD PILA.
- Main track later only after workshop-quality evidence plus stronger novelty.
