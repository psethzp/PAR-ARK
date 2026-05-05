#!/usr/bin/env bash
set -euo pipefail

# Optional. Run only if Stage E/F finish early. Profile mode is cheaper to analyze than full trace mode
# and checks whether the profile block alone is the harmful component.

export WORKDIR=${WORKDIR:-$HOME/par_ark_workspace}
cd "$WORKDIR/ark"
export VLLM_PORT=${VLLM_PORT:-8000}
MODEL=${MODEL:-Qwen/Qwen3-30B-A3B-Instruct-2507}
SPLIT=${SPLIT:-test}
LIMIT=${LIMIT:-150}
MAX_STEPS=${MAX_STEPS:-12}
AGENTS=${AGENTS:-1}

for GRAPH in prime mag amazon; do
  MODE=profile
  TAG="deadline_profile_probe_q30b_limit${LIMIT}_s${MAX_STEPS}"
  echo "[Profile probe] graph=$GRAPH tag=$TAG"
  uv run python par_main.py \
    --graph_name "$GRAPH" \
    --model_name "$MODEL" \
    --split "$SPLIT" \
    --limit "$LIMIT" \
    --number_of_agents "$AGENTS" \
    --max_steps "$MAX_STEPS" \
    --par_mode "$MODE" \
    --run_tag "$TAG" || true
  uv run python par_eval.py \
    --graph_name "$GRAPH" \
    --model_name "$MODEL" \
    --split "$SPLIT" \
    --run_tag "$TAG" \
    --par_mode "$MODE" \
    --max_agents "$AGENTS" || true
done
