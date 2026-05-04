## Final answer: yes, still doable GPU-only — but not as “guaranteed A* main”

I’m going to be blunt: **no setup can guarantee A*/Core-A main-track acceptance**, and without GPT/API you should **not** frame the target as “we beat closed-model ARK/GPT-4.1.” ARK’s own paper says its primary config uses GPT-4.1, and its STaRK table reports **59.14 Avg Hit@1 / 71.51 Avg Recall@20 / 67.44 Avg MRR**; that is the closed-model upper bound you cite, not the number you promise to beat. ([arXiv][1])

The right claim is:

> **PAR-ARK is the best local/open-weight adaptive KG retrieval plan under fixed GPU compute, improving over same-backbone ARK-local while narrowing the gap to closed-model ARK.**

That has a real workshop chance, and a main-track chance only if the numbers are very strong plus the trace/failure analysis is excellent.

I made the full agent-ready package here: [Download the PAR-ARK GPU-only package](sandbox:/mnt/data/par_ark_gpu_package_2026_05_04.zip).

---

## Model decision

Use this exact stack:

| Stage               | Model                              |                          GPU plan | Why                                                                                                                                                                 |
| ------------------- | ---------------------------------- | --------------------------------: | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Smoke/dev           | `Qwen/Qwen3-8B`                    |                            1× L40 | Fast tool-calling/debug model; Qwen3-8B has 8.2B params, 36 layers, GQA, and 32k native context. ([Hugging Face][2])                                                |
| Main ablations      | `Qwen/Qwen3-14B`                   |                            1× L40 | Best quality/safety balance for lots of runs; 14.8B params, 40 layers, 32k native context. ([Hugging Face][3])                                                      |
| Final local teacher | `Qwen/Qwen3-30B-A3B-Instruct-2507` |                       2× L40 TP=2 | Strongest no-GPT controller that should fit; 30.5B total params, 3.3B activated, 48 layers, 4 KV heads, 262k native context, non-thinking mode. ([Hugging Face][4]) |
| Optional reranker   | `Qwen/Qwen3-Reranker-8B`           | 1× L40, after stopping controller | Strong reranker stage; Qwen3 reranker series includes 8B, 32k context, and SentenceTransformers usage. ([Hugging Face][5])                                          |
| Fallback reranker   | `BAAI/bge-reranker-v2-m3`          |                     1× L40 or CPU | Small fast fallback, not main claim. ([Hugging Face][6])                                                                                                            |

Do **not** load controller + reranker together. Your L40 has **48GB GDDR6 ECC**, so one large model at a time is the safe policy. ([NVIDIA][7])

---

## VRAM calculation

Approximate BF16 weight memory:

```text
weights_GB ≈ parameters_B × 2
```

Approximate KV cache per sequence:

```text
KV_bytes ≈ 2 × layers × KV_heads × head_dim × bytes × context_tokens
```

| Model           |  BF16 weights |           KV @16k |           KV @32k | Safe setting                   |
| --------------- | ------------: | ----------------: | ----------------: | ------------------------------ |
| Qwen3-8B        |       ~16.4GB |          ~2.25GiB |          ~4.50GiB | 1× L40 easy                    |
| Qwen3-14B       |       ~29.6GB |          ~2.50GiB |          ~5.00GiB | 1× L40 at 16k; 32k maybe tight |
| Qwen3-30B-A3B   | ~61.0GB total | ~1.50GiB total KV | ~3.00GiB total KV | 2× L40 TP=2 at 32k             |
| Qwen3-32B dense |       ~65.6GB |          ~4.00GiB |          ~8.00GiB | riskier; skip                  |

Final serving command in the package uses:

```bash
vllm serve Qwen/Qwen3-30B-A3B-Instruct-2507 \
  --tensor-parallel-size 2 \
  --max-model-len 32768 \
  --max-num-seqs 1 \
  --gpu-memory-utilization 0.90
```

Qwen’s official docs show vLLM serving for Qwen3 models and that it exposes an OpenAI-compatible API at localhost, which matches ARK’s Qwen/vLLM path. ([GitHub][8])

---

## How you compete against SOTA without GPT

You do **not** say “we beat GPT-ARK” unless the numbers do. You run:

1. **ARK-local, Qwen3-14B**
2. **PAR-ARK, Qwen3-14B**
3. **ARK-local, Qwen3-30B-A3B**
4. **PAR-ARK, Qwen3-30B-A3B**
5. Optional: **PAR-ARK + Qwen3-Reranker-8B**
6. Optional: **PAR-ARK distilled Qwen3-8B**

Then cite published SOTA rows: BM25, GritLM, KAR, mFAR, MoR, GraphFlow, AvaTaR, ARK distilled, and ARK closed-model. ARK’s paper explicitly reports the same STaRK metric family: Hit@1, Hit@5, Recall@20, and MRR. ([arXiv][1])

The acceptance story becomes:

> “Closed-model ARK is strong but hard to reproduce for GPU-only labs. PAR-ARK makes adaptive KG retrieval local, trace-aware, and profile-conditioned, and improves same-backbone open-weight ARK under matched compute.”

That is a much better story than pretending open Qwen will automatically beat GPT-4.1.

---

## What the package contains

The zip has:

```text
README_AGENT_START_HERE.md
REPORT_FOR_HUMAN.md

docs/
  01_sota_acceptance_and_claims.md
  02_gpu_memory_calculations.md
  03_method_spec.md
  04_experiment_matrix.md
  05_rerank_and_distill.md

configs/
  model_matrix.yaml
  par_ark_defaults.yaml

scripts/
  00_create_workspace.sh
  01_setup_env.sh
  02_get_data_and_preprocess.sh
  03_apply_overlay.sh
  04_serve_qwen3_8b_1gpu.sh
  05_smoke_prime.sh
  06_stop_vllm.sh
  07_serve_qwen3_14b_1gpu.sh
  08_run_val_ablation_grid.sh
  09_serve_qwen3_30b_a3b_tp2.sh
  10_run_final_tests.sh
  11_collect_tables.sh
  12_rerank_final_candidates.sh

patches/
  apply_par_ark_overlay.py

paper/
  outline_workshop.md
  latex_skeleton.tex

results_templates/
  main_table_template.md
  ablation_table_template.md
```

The overlay adds a separate `par_main.py`, `par_eval.py`, PAR prompt, profile extractor, trace controller, offline reranking script, and table collector. It avoids directly rewriting ARK’s original files.

---

## Core method: 2 major + 4 minor changes

### Major 1 — Profile-Conditioned Action Prior

Before retrieval, build a query/profile JSON:

```json
{
  "target_entity_type": "paper",
  "must_cover_facets": ["graph retrieval", "personalization", "reasoning"],
  "relation_hints": ["cites", "authored_by"],
  "search_bias": "start broad, then traverse relation-filtered neighborhoods"
}
```

On STaRK alone, call this **query-profile conditioning**, not full personalization. For true personalization, add a small PBR/PersonaBench side experiment, because PBR specifically argues for incorporating user-specific signals before retrieval and reports gains on PersonaBench. ([arXiv][9])

### Major 2 — Trace-State Evidence Sufficiency and Repair

After every tool call, log:

```text
tool name
arguments
result count
zero-result flag
repeated-call flag
global/neighborhood count
selected answer count
repair hint
```

Then inject a short hint:

```text
[PAR-ARK TRACE HINT] Neighborhood failed: relax node_type or edge_type, or re-anchor globally using the missing facet.
```

This is your “reasoning in retrieval” contribution.

### Minor changes

1. Hard budget controller: max global searches, max neighborhood searches, max steps.
2. Sequential multi-agent aggregation: avoids vLLM OOM.
3. Tool-call cache/dedup: prevents repeated useless calls.
4. Offline reranking: stop vLLM, rerank candidates with Qwen3-Reranker-8B.
5. Optional local self-distillation: Qwen3-30B-A3B PAR-ARK trajectories → Qwen3-8B LoRA student.

ARK already supports Qwen3-8B distillation-style fine-tuning and reports label-free trajectory imitation as part of its method, so the local self-distillation path is aligned with the base codebase. ([GitHub][10])

---

## Exact execution path

After unzipping:

```bash
cd par_ark_gpu_package_2026_05_04
export PACKAGE_DIR=$PWD
export WORKDIR=$HOME/par_ark_workspace

bash scripts/00_create_workspace.sh
bash scripts/01_setup_env.sh
bash scripts/02_get_data_and_preprocess.sh
bash scripts/03_apply_overlay.sh
```

STaRK can be installed through `stark-qa`, and the docs show `load_skb`, `load_qa`, synthetic splits, and `human_generated_eval=True`. ([Stark][11])

Smoke:

```bash
bash scripts/04_serve_qwen3_8b_1gpu.sh
# in another shell:
bash scripts/05_smoke_prime.sh
bash scripts/06_stop_vllm.sh
```

Ablations:

```bash
bash scripts/07_serve_qwen3_14b_1gpu.sh
# another shell:
bash scripts/08_run_val_ablation_grid.sh
bash scripts/06_stop_vllm.sh
```

Final teacher:

```bash
bash scripts/09_serve_qwen3_30b_a3b_tp2.sh
# another shell:
bash scripts/10_run_final_tests.sh
bash scripts/11_collect_tables.sh
```

Optional rerank:

```bash
bash scripts/06_stop_vllm.sh
bash scripts/12_rerank_final_candidates.sh
bash scripts/11_collect_tables.sh
```

---

## Venue route

For **A*/Core-A main**, the chance is not something I’d call high in 2–3 days unless results are genuinely surprising. NeurIPS main is not a good fit for your “acceptance by May/June” constraint: abstract is **May 4, 2026**, full paper is **May 6, 2026**, and notification is **September 24, 2026**. ([NeurIPS][12])

Best route now:

| Priority | Venue                                 | Why                                                                                                                                   |
| -------: | ------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------- |
|        1 | ICML Graph Foundation Models workshop | Deadline May 8; graph + foundation model + KG retrieval fit. ([OpenReview][13])                                                       |
|        2 | KDD PILA                              | Best if you emphasize personalized/profile-conditioned agents; abstract May 19, paper May 21, notification June 10. ([PILA 2026][14]) |
|        3 | KDD / ICML agent evaluation workshops | Best if metrics are mixed but trace diagnostics are strong.                                                                           |
|        4 | Main-track later                      | Use workshop paper as prototype, then expand with more human eval, personalization, and stronger analysis.                            |

---

## Bottom line

Use the package as-is. The “guaranteed acceptance” version is not an A* main claim; it is a **very well-matched workshop submission** with clean local reproducibility, strong ablations, and honest comparison against closed-model ARK.

Package link again: [Download the PAR-ARK GPU-only package](sandbox:/mnt/data/par_ark_gpu_package_2026_05_04.zip).

[1]: https://arxiv.org/html/2601.13969v2 "https://arxiv.org/html/2601.13969v2"
[2]: https://huggingface.co/Qwen/Qwen3-8B "https://huggingface.co/Qwen/Qwen3-8B"
[3]: https://huggingface.co/Qwen/Qwen3-14B "https://huggingface.co/Qwen/Qwen3-14B"
[4]: https://huggingface.co/Qwen/Qwen3-30B-A3B-Instruct-2507 "https://huggingface.co/Qwen/Qwen3-30B-A3B-Instruct-2507"
[5]: https://huggingface.co/Qwen/Qwen3-Reranker-8B "https://huggingface.co/Qwen/Qwen3-Reranker-8B"
[6]: https://huggingface.co/BAAI/bge-reranker-v2-m3 "https://huggingface.co/BAAI/bge-reranker-v2-m3"
[7]: https://www.nvidia.com/en-us/data-center/l40/ "https://www.nvidia.com/en-us/data-center/l40/"
[8]: https://github.com/QwenLM/Qwen3 "https://github.com/QwenLM/Qwen3"
[9]: https://arxiv.org/abs/2510.08935 "https://arxiv.org/abs/2510.08935"
[10]: https://github.com/mims-harvard/ark "https://github.com/mims-harvard/ark"
[11]: https://stark.stanford.edu/get_started.html "https://stark.stanford.edu/get_started.html"
[12]: https://neurips.cc/Conferences/2026/CallForPapers "https://neurips.cc/Conferences/2026/CallForPapers"
[13]: https://openreview.net/group?id=ICML.cc%2F2026%2FWorkshop%2FGFM&referrer=%5BHomepage%5D%28%2F%29 "https://openreview.net/group?id=ICML.cc%2F2026%2FWorkshop%2FGFM&referrer=%5BHomepage%5D%28%2F%29"
[14]: https://pila26-workshop.github.io/ "https://pila26-workshop.github.io/"
