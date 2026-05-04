# PAR-ARK End-to-End Execution Plan

## Summary
This repo is a GPU-only PAR-ARK wrapper package, not the ARK repo itself. The intended flow is: clone upstream ARK into `~/par_ark_workspace/ark`, install a local Qwen/vLLM environment, download STaRK data and Qwen models, apply the PAR-ARK overlay, run smoke tests, run validation ablations, run final test experiments, optionally rerank/distill, then collect paper tables.

The machine has 4 visible L40S GPUs and enough disk. Because GPUs `0` and `1` are currently partly occupied, default to `CUDA_VISIBLE_DEVICES=2` for 1-GPU runs and `CUDA_VISIBLE_DEVICES=2,3` for 2-GPU final teacher runs unless usage changes.

## Stage Plan

### 0. Preflight And Repo Sanity
- Confirm hardware before every long run:
  - `nvidia-smi`
  - `df -h`
  - `curl https://huggingface.co`
- Use a compatible Python runtime for vLLM/Torch. System Python is `3.13`, so prefer `uv python install 3.11` and run setup with `UV_PYTHON=3.11`.
- Confirm the package scripts are syntactically valid:
  - `bash -n scripts/*.sh`
  - `python3 -m py_compile patches/apply_par_ark_overlay.py`
- Confirm Hugging Face model access for:
  - `Qwen/Qwen3-8B`
  - `Qwen/Qwen3-14B`
  - `Qwen/Qwen3-30B-A3B-Instruct-2507`
  - `Qwen/Qwen3-Reranker-8B`

### 1. Create Workspace
- Set:
  - `export PACKAGE_DIR=/home/ubuntu/nachiket/Ablations/PStuff/PAR-ARK`
  - `export WORKDIR=$HOME/par_ark_workspace`
- Run `bash scripts/00_create_workspace.sh`.
- Expected result:
  - upstream ARK exists at `$WORKDIR/ark`;
  - `$WORKDIR/ARK_COMMIT.txt` records the ARK commit;
  - no changes are made to this wrapper repo.

### 2. Environment Setup
- Run with Python 3.11 selected:
  - `UV_PYTHON=3.11 bash scripts/01_setup_env.sh`
- Expected result:
  - `$WORKDIR/ark/.venv` exists;
  - `uv run python -c "import torch, vllm, pandas, stark_qa"` works;
  - `.env` contains local `VLLM_PORT=8000`;
  - no OpenAI/GPT/Azure API keys are required for controller runs.
- If vLLM install fails, fix environment before data/model downloads; do not continue to experiments.

### 3. Data Setup And Validation
- Run `bash scripts/02_get_data_and_preprocess.sh`.
- Then verify ARK’s expected layout, because STaRK cache layout can differ:
  - `data/graphs/{prime,mag,amazon}/nodes.parquet`
  - `data/graphs/{prime,mag,amazon}/edges.parquet`
  - `data/qa/{prime,mag,amazon}/stark_qa/stark_qa.csv`
  - `data/qa/{prime,mag,amazon}/split/test.index`
- If `val.index` is missing, use `SPLIT=test LIMIT=100` only for tuning and reserve full `test` for final reporting.
- If graph parquet files are missing, run ARK’s own `preprocessing/*.py` scripts from `$WORKDIR/ark`, then re-check paths.

### 4. Apply PAR-ARK Overlay
- Run `bash scripts/03_apply_overlay.sh`.
- Expected added files inside `$WORKDIR/ark`:
  - `par_main.py`
  - `par_eval.py`
  - `src/agents/graph_explorer/par_profile.py`
  - `src/agents/graph_explorer/par_trace.py`
  - `src/agents/graph_explorer/par_graph_explorer.py`
  - `scripts/make_par_tables.py`
  - `scripts/offline_rerank_qwen3.py`
- Validate immediately:
  - `cd $WORKDIR/ark`
  - `uv run python -m py_compile par_main.py par_eval.py src/agents/graph_explorer/par_*.py scripts/make_par_tables.py scripts/offline_rerank_qwen3.py`

### 5. Model Download And vLLM Smoke Server
- Start smallest server first:
  - `CUDA_VISIBLE_DEVICES=2 bash scripts/04_serve_qwen3_8b_1gpu.sh`
- In another shell, verify the local API:
  - `curl http://localhost:8000/v1/models`
- Run a tiny manual tool-call probe if needed, then run:
  - `bash scripts/05_smoke_prime.sh`
- Success criteria:
  - 20 PRIME examples complete;
  - `par_eval.py` prints metrics;
  - logs contain `par_trace_summary`;
  - no repeated crash, no OOM, and no empty output directory.
- Stop server after smoke:
  - `bash scripts/06_stop_vllm.sh`

### 6. Validation Ablation Grid
- Start 14B server:
  - `CUDA_VISIBLE_DEVICES=2 bash scripts/07_serve_qwen3_14b_1gpu.sh`
- Run validation:
  - if `val` exists: `bash scripts/08_run_val_ablation_grid.sh`
  - if not: `SPLIT=test LIMIT=100 bash scripts/08_run_val_ablation_grid.sh`
- Compare variants:
  - `off`: same-backbone ARK-local baseline;
  - `profile`: profile-conditioned action prior only;
  - `trace`: trace repair only;
  - `full`: profile + trace + budget controller.
- Selection rule for final:
  - choose the lowest-cost setting that improves Hit@1/MRR or clearly reduces wasted calls without hurting Recall@20;
  - default to `full`, `max_steps=16`, one agent if results are mixed.

### 7. Final Teacher Experiments
- Stop 14B server:
  - `bash scripts/06_stop_vllm.sh`
- Start 30B-A3B teacher on two free GPUs:
  - `CUDA_VISIBLE_DEVICES=2,3 bash scripts/09_serve_qwen3_30b_a3b_tp2.sh`
- Run final tests:
  - `MAX_STEPS=16 AGENTS=1 bash scripts/10_run_final_tests.sh`
- Required final rows:
  - ARK-local Qwen3-30B-A3B on `prime`, `mag`, `amazon`;
  - PAR-ARK-full Qwen3-30B-A3B on `prime`, `mag`, `amazon`.
- Optional after stable single-agent final:
  - run `AGENTS=3` sequential only, not parallel, if time allows.

### 8. Optional Reranking
- Only run reranking after stopping controller vLLM:
  - `bash scripts/06_stop_vllm.sh`
  - `CUDA_VISIBLE_DEVICES=2 bash scripts/12_rerank_final_candidates.sh`
- Report rerank as a separate row: `PAR-ARK-full+rerank`.
- Do not make reranking the main claim unless candidate recall is already strong.

### 9. Optional Self-Distillation
- Generate teacher trajectories from Qwen3-30B-A3B PAR-ARK-full on train/val subsets.
- Adapt ARK fine-tuning to read PAR logs or copy PAR logs into ARK’s expected trajectory directory.
- LoRA fine-tune Qwen3-8B for one epoch with max length `16384`.
- Evaluate student against Qwen3-8B ARK-local and Qwen3-8B PAR-ARK-full.
- Treat this as an efficiency extension, not the core result.

### 10. Tables, Paper Evidence, And Claims
- Run:
  - `bash scripts/11_collect_tables.sh`
- Required outputs:
  - main quality table: Hit@1, Hit@5, Recall@20, MRR;
  - same-backbone ablation table;
  - budget/tool table: steps, global searches, neighborhood searches, zero-result calls, repeated calls, runtime;
  - 3 qualitative trace-repair examples.
- Claim defensibly:
  - “local/open-weight adaptive KG retrieval improves over same-backbone ARK-local under matched compute.”
- Do not claim:
  - guaranteed main-track acceptance;
  - true personalization from STaRK-only experiments;
  - SOTA over GPT-ARK unless the final numbers actually beat it.

## Interfaces And CLI Defaults
- Main execution entrypoint after overlay: `par_main.py`.
- Main evaluation entrypoint after overlay: `par_eval.py`.
- Important CLI knobs:
  - `--graph_name prime|mag|amazon`
  - `--model_name Qwen/...`
  - `--split val|test`
  - `--limit N`
  - `--max_steps 12|16`
  - `--par_mode off|profile|trace|full`
  - `--number_of_agents 1`
  - `--run_tag TAG`
- Default production settings:
  - 8B smoke: 1 GPU, `max_model_len=16384`;
  - 14B validation: 1 GPU, `max_model_len=16384`;
  - 30B-A3B final: 2 GPUs, tensor parallel size 2, `max_model_len=32768`;
  - never load controller and reranker at the same time.

## Acceptance Tests
- Setup passes: imports for `torch`, `vllm`, `stark_qa`, `sentence_transformers`.
- Data passes: each graph has parquet graph files and QA split files.
- Overlay passes: all generated PAR files compile.
- Server passes: `/v1/models` returns the served Qwen model.
- Smoke passes: PRIME limit-20 run produces JSON logs, metrics, and trace summaries.
- Validation passes: at least one complete grid over all three graphs and four modes.
- Final passes: full test runs complete for ARK-local and PAR-ARK-full on all three STaRK graphs.
- Reporting passes: `paper_tables/par_ark_tables.md` contains all final metric rows.

## Assumptions
- Use `$HOME/par_ark_workspace` as the execution workspace.
- Use GPUs `2` and `3` unless `nvidia-smi` shows a better free pair.
- Use Qwen3 open-weight models only; no GPT/OpenAI/Azure controller calls.
- Use BF16 for final quality runs.
- Use `val` for tuning if available; otherwise use limited `test` for tuning and reserve full `test` for final.
