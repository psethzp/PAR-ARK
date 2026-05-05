#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib_parark_runtime.sh"

STAGE=17_run_stage_b2_30b_pilot
stage_status "$STAGE" "RUNNING" "Qwen3-30B-A3B pilot calibration"

cd "$WORKDIR/ark"
export VLLM_PORT=${VLLM_PORT:-8000}

MODEL="Qwen/Qwen3-30B-A3B-Instruct-2507"
SPLIT=${SPLIT:-test}
LIMIT=${LIMIT:-50}
MAX_STEPS=${MAX_STEPS:-16}
AGENTS=${AGENTS:-1}

curl -sSf "http://localhost:${VLLM_PORT}/v1/models" >/dev/null

for GRAPH in prime mag amazon; do
  for MODE in off full; do
    TAG="stage_b2_pilot_${MODE}_q30b_limit${LIMIT}"
    heartbeat "$STAGE" "graph=$GRAPH mode=$MODE split=$SPLIT limit=$LIMIT steps=$MAX_STEPS"
    uv run python par_main.py \
      --graph_name "$GRAPH" \
      --model_name "$MODEL" \
      --split "$SPLIT" \
      --limit "$LIMIT" \
      --number_of_agents "$AGENTS" \
      --max_steps "$MAX_STEPS" \
      --par_mode "$MODE" \
      --run_tag "$TAG"
    checkpoint "$STAGE" "generation graph=$GRAPH mode=$MODE limit=$LIMIT"
    uv run python par_eval.py \
      --graph_name "$GRAPH" \
      --model_name "$MODEL" \
      --split "$SPLIT" \
      --run_tag "$TAG" \
      --par_mode "$MODE" \
      --max_agents "$AGENTS"
    checkpoint "$STAGE" "eval graph=$GRAPH mode=$MODE limit=$LIMIT"
    require_disk_budget
  done
done

stage_status "$STAGE" "SUCCEEDED" "30B-A3B pilot complete"
