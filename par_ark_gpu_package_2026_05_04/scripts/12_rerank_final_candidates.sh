#!/usr/bin/env bash
set -euo pipefail
# Run only after stopping controller vLLM: bash scripts/06_stop_vllm.sh
export WORKDIR=${WORKDIR:-$HOME/par_ark_workspace}
cd "$WORKDIR/ark"
MODEL_SHORT="Qwen3-30B-A3B-Instruct-2507"
RERANKER=${RERANKER:-Qwen/Qwen3-Reranker-8B}
for GRAPH in prime mag amazon; do
  IN="data/experiments/${GRAPH}/graph_explorer_${MODEL_SHORT}_par_full_final_parark_q30b_a1/test"
  OUT="data/experiments/${GRAPH}/graph_explorer_${MODEL_SHORT}_par_full_reranked_qwen3/test"
  uv run python scripts/offline_rerank_qwen3.py --graph_name "$GRAPH" --in_logs_dir "$IN" --out_logs_dir "$OUT" --reranker_model "$RERANKER" --max_candidates 50 --batch_size 2
  uv run python par_eval.py --graph_name "$GRAPH" --logs_dir "$OUT" --max_agents 1
done
