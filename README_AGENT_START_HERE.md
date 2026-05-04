# PAR-ARK GPU-Only Execution Package — Start Here

Date locked: 2026-05-04  
Hardware target: 2× NVIDIA L40, 48GB VRAM each.  
Constraint: no GPT/OpenAI/Azure APIs. All controllers must use local/open-weight models.

## Hard decision

Do **not** try to beat the closed-model ARK paper as the only acceptance claim. ARK's primary reported configuration uses GPT-4.1 and reports 59.14 average Hit@1 / 71.51 Recall@20 / 67.44 MRR on STaRK synthetic test. Without closed models, the paper should claim:

> Open-weight, GPU-local adaptive KG retrieval with trace-state control and profile-conditioned action priors; improves over same-backbone ARK-local and narrows the gap to closed-model ARK under fixed compute.

That is publishable if numbers and analysis are solid. It is **not guaranteed** for any main track. The high-probability route is ICML/KDD workshop first, then extend to main-track later.

## Recommended model stack

Use staged loading. Never load controller + reranker + trainer at the same time.

1. Dev/smoke: `Qwen/Qwen3-8B` BF16 on 1 L40.
2. Main ablations: `Qwen/Qwen3-14B` BF16 on 1 L40 with `max_model_len=16384`.
3. Strong final local teacher: `Qwen/Qwen3-30B-A3B-Instruct-2507` BF16 on 2 L40 via vLLM TP=2 with `max_model_len=32768`.
4. Optional rerank stage: stop vLLM, then load `Qwen/Qwen3-Reranker-8B` or fallback `BAAI/bge-reranker-v2-m3`.
5. Optional student: self-distill `Qwen/Qwen3-8B` from your Qwen3-30B-A3B PAR-ARK trajectories using LoRA.

## Stage order

1. Create workspace and clone ARK.
2. Install uv/vLLM and STaRK data.
3. Apply PAR-ARK overlay.
4. Run smoke on PRIME with Qwen3-8B.
5. Run local ARK baseline with Qwen3-14B on val subset.
6. Run PAR-ARK ablations with Qwen3-14B on val subset.
7. Run final teacher with Qwen3-30B-A3B on test.
8. Evaluate and collect tables.
9. Optional reranker and optional self-distillation.
10. Write workshop paper using the included outline.

## Main commands after copying this package to the machine

```bash
bash scripts/00_create_workspace.sh
bash scripts/01_setup_env.sh
bash scripts/02_get_data_and_preprocess.sh
bash scripts/03_apply_overlay.sh
bash scripts/04_serve_qwen3_8b_1gpu.sh
bash scripts/05_smoke_prime.sh
bash scripts/06_stop_vllm.sh
bash scripts/07_serve_qwen3_14b_1gpu.sh
bash scripts/08_run_val_ablation_grid.sh
bash scripts/06_stop_vllm.sh
bash scripts/09_serve_qwen3_30b_a3b_tp2.sh
bash scripts/10_run_final_tests.sh
bash scripts/11_collect_tables.sh
```

Read `docs/02_gpu_memory_calculations.md` before changing model/context settings.
