#!/usr/bin/env bash
set -euo pipefail

export WORKDIR=${WORKDIR:-$HOME/par_ark_workspace}
cd "$WORKDIR/ark"
export VLLM_PORT=${VLLM_PORT:-8000}
MODEL=${MODEL:-Qwen/Qwen3-30B-A3B-Instruct-2507}
SPLIT=${SPLIT:-test}
LIMIT=${LIMIT:-300}
MAX_STEPS=${MAX_STEPS:-16}
AGENTS=${AGENTS:-1}

printf '\n[Stage E] 30B subset: split=%s limit=%s steps=%s model=%s\n' "$SPLIT" "$LIMIT" "$MAX_STEPS" "$MODEL"
printf '[Stage E] Workload = 3 graphs x 2 modes x %s = %s questions\n\n' "$LIMIT" "$((3*2*LIMIT))"

for GRAPH in prime mag amazon; do
  for MODE in off full; do
    TAG="deadline_${MODE}_q30b_limit${LIMIT}_s${MAX_STEPS}"
    echo "[Stage E] graph=$GRAPH mode=$MODE tag=$TAG"
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
done

mkdir -p paper_tables
uv run python scripts/make_par_tables.py --out paper_tables/deadline_stage_e_tables.md || true
echo "[Stage E] Done. Tables: $WORKDIR/ark/paper_tables/deadline_stage_e_tables.md"
