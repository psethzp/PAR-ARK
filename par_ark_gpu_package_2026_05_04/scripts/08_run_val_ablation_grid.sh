#!/usr/bin/env bash
set -euo pipefail
export WORKDIR=${WORKDIR:-$HOME/par_ark_workspace}
cd "$WORKDIR/ark"
export VLLM_PORT=${VLLM_PORT:-8000}
MODEL="Qwen/Qwen3-14B"
SPLIT=${SPLIT:-val}
LIMIT=${LIMIT:-100}
for GRAPH in prime mag amazon; do
  for MODE in off profile trace full; do
    for STEPS in 12 16; do
      TAG="val_${MODE}_steps${STEPS}_limit${LIMIT}"
      uv run python par_main.py --graph_name "$GRAPH" --model_name "$MODEL" --split "$SPLIT" --limit "$LIMIT" --number_of_agents 1 --max_steps "$STEPS" --par_mode "$MODE" --run_tag "$TAG" || true
      uv run python par_eval.py --graph_name "$GRAPH" --model_name "$MODEL" --split "$SPLIT" --run_tag "$TAG" --par_mode "$MODE" --max_agents 1 || true
    done
  done
done
