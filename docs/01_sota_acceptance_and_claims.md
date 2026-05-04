# SOTA, Acceptance Reality, and Safe Claims

## Current SOTA anchor

Base repository: https://github.com/mims-harvard/ark  
Paper: https://arxiv.org/html/2601.13969v2

ARK is the correct base because it already formulates KG retrieval as adaptive breadth-depth exploration with two tools:

- Global Search: BM25 over node descriptors.
- Neighborhood Exploration: one-hop expansion, composable into multi-hop traversal.

ARK reports on STaRK synthetic test:

| Method | Avg Hit@1 | Avg R@20 | Avg MRR |
|---|---:|---:|---:|
| BM25 | 27.85 | 43.57 | 36.68 |
| GritLM-7B | 31.85 | 47.34 | 41.61 |
| KAR | 45.01 | 56.11 | 52.67 |
| mFAR | 49.63 | 71.00 | 60.20 |
| MoR | 48.93 | 66.14 | 58.77 |
| GraphFlow | 46.11 | 57.68 | 54.89 |
| AvaTaR | 37.55 | 50.18 | 45.53 |
| ARK distilled | 49.51 | 66.31 | 58.47 |
| ARK closed-model | 59.14 | 71.51 | 67.44 |

## What we can claim without GPT/API

Strong, defensible claim:

> We introduce PAR-ARK, a profile-conditioned, trace-aware controller for open-weight adaptive KG retrieval. On STaRK, PAR-ARK improves same-backbone ARK-local under matched compute, reduces wasted graph actions, and provides interpretable failure traces. A Qwen3-30B-A3B teacher and optional Qwen3-8B self-distilled student run entirely on local GPUs.

Do **not** claim:

- guaranteed SOTA over GPT-4.1 ARK unless the numbers actually exceed ARK's closed-model table;
- true personalization on STaRK alone, unless a user-profile benchmark is run;
- main-track acceptance guarantee.

## Venue strategy

1. If STaRK improves with Qwen3-30B-A3B and ablations are clean: ICML Graph Foundation Models workshop.
2. If metrics are flat but failure traces/repairs are strong: ICML failure-mode / diagnostics workshop.
3. If profile/personalization side results are strong: KDD PILA workshop.
4. If you need main-track: extend after workshop with more runs, stronger theory/analysis, and human-generated STaRK + personalization benchmark.

Acceptance can never be guaranteed. The closest practical guarantee is to submit to a well-fitting workshop with a careful paper and reproducibility package.
