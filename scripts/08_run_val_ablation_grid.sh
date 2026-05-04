#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib_parark_runtime.sh"
STAGE=08_run_val_ablation_grid
stage_status "$STAGE" "RUNNING" "Qwen3-14B validation ablation grid"
cd "$WORKDIR/ark"
export VLLM_PORT=${VLLM_PORT:-8000}
MODEL="Qwen/Qwen3-14B"
SPLIT=${SPLIT:-val}
LIMIT=${LIMIT:-100}
curl -sSf "http://localhost:${VLLM_PORT}/v1/models" >/dev/null
if [ ! -f "data/qa/prime/split/${SPLIT}.index" ]; then
  echo "Split ${SPLIT} not found; falling back to SPLIT=test LIMIT=${LIMIT}"
  SPLIT=test
fi
for GRAPH in prime mag amazon; do
  for MODE in off profile trace full; do
    for STEPS in 12 16; do
      TAG="val_${MODE}_steps${STEPS}_limit${LIMIT}"
      heartbeat "$STAGE" "graph=$GRAPH mode=$MODE steps=$STEPS split=$SPLIT limit=$LIMIT"
      uv run python par_main.py --graph_name "$GRAPH" --model_name "$MODEL" --split "$SPLIT" --limit "$LIMIT" --number_of_agents 1 --max_steps "$STEPS" --par_mode "$MODE" --run_tag "$TAG"
      checkpoint "$STAGE" "generation graph=$GRAPH mode=$MODE steps=$STEPS"
      uv run python par_eval.py --graph_name "$GRAPH" --model_name "$MODEL" --split "$SPLIT" --run_tag "$TAG" --par_mode "$MODE" --max_agents 1
      checkpoint "$STAGE" "eval graph=$GRAPH mode=$MODE steps=$STEPS"
      require_disk_budget
    done
  done
done
stage_status "$STAGE" "SUCCEEDED" "validation grid complete"
