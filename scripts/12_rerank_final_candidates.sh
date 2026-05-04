#!/usr/bin/env bash
set -euo pipefail
# Run only after stopping controller vLLM: bash scripts/06_stop_vllm.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib_parark_runtime.sh"
STAGE=12_rerank_final_candidates
stage_status "$STAGE" "RUNNING" "offline reranking"
require_disk_budget
cd "$WORKDIR/ark"
export CUDA_VISIBLE_DEVICES=${CUDA_VISIBLE_DEVICES:-$PARARK_GPU_1}
MODEL_SHORT="Qwen3-30B-A3B-Instruct-2507"
RERANKER=${RERANKER:-Qwen/Qwen3-Reranker-8B}
for GRAPH in prime mag amazon; do
  heartbeat "$STAGE" "graph=$GRAPH reranker=$RERANKER"
  IN="data/experiments/${GRAPH}/graph_explorer_${MODEL_SHORT}_par_full_final_parark_q30b_a1/test"
  OUT="data/experiments/${GRAPH}/graph_explorer_${MODEL_SHORT}_par_full_reranked_qwen3/test"
  uv run python scripts/offline_rerank_qwen3.py --graph_name "$GRAPH" --in_logs_dir "$IN" --out_logs_dir "$OUT" --reranker_model "$RERANKER" --max_candidates 50 --batch_size 2
  checkpoint "$STAGE" "reranked graph=$GRAPH"
  uv run python par_eval.py --graph_name "$GRAPH" --logs_dir "$OUT" --max_agents 1
  checkpoint "$STAGE" "rerank eval graph=$GRAPH"
  require_disk_budget
done
stage_status "$STAGE" "SUCCEEDED" "offline reranking complete"
