#!/usr/bin/env bash
set -euo pipefail

export WORKDIR=${WORKDIR:-$HOME/par_ark_workspace}
cd "$WORKDIR/ark"
export VLLM_PORT=${VLLM_PORT:-8000}
MODEL=${MODEL:-Qwen/Qwen3-30B-A3B-Instruct-2507}
SPLIT=${SPLIT:-test}
LIMIT=${LIMIT:-150}
MAX_STEPS=${MAX_STEPS:-8}
MAX_GLOBAL=${MAX_GLOBAL:-2}
MAX_NEIGH=${MAX_NEIGH:-3}
MAX_OBS=${MAX_OBS:-2500}
MAX_ANS=${MAX_ANS:-10}
AGENTS=${AGENTS:-1}

printf '\n[Stage F] budget-fix probe: split=%s limit=%s steps=%s global=%s neigh=%s obs=%s answers=%s\n\n' \
  "$SPLIT" "$LIMIT" "$MAX_STEPS" "$MAX_GLOBAL" "$MAX_NEIGH" "$MAX_OBS" "$MAX_ANS"

for GRAPH in prime mag amazon; do
  MODE=full
  TAG="deadline_budgetfix_q30b_limit${LIMIT}_s${MAX_STEPS}_g${MAX_GLOBAL}_n${MAX_NEIGH}_obs${MAX_OBS}"
  echo "[Stage F] graph=$GRAPH mode=$MODE tag=$TAG"
  uv run python par_main.py \
    --graph_name "$GRAPH" \
    --model_name "$MODEL" \
    --split "$SPLIT" \
    --limit "$LIMIT" \
    --number_of_agents "$AGENTS" \
    --max_steps "$MAX_STEPS" \
    --par_mode "$MODE" \
    --max_global_searches "$MAX_GLOBAL" \
    --max_neighborhood_searches "$MAX_NEIGH" \
    --max_observation_chars "$MAX_OBS" \
    --max_answers "$MAX_ANS" \
    --run_tag "$TAG" || true
  uv run python par_eval.py \
    --graph_name "$GRAPH" \
    --model_name "$MODEL" \
    --split "$SPLIT" \
    --run_tag "$TAG" \
    --par_mode "$MODE" \
    --max_agents "$AGENTS" || true
done

mkdir -p paper_tables
uv run python scripts/make_par_tables.py --out paper_tables/deadline_stage_f_budgetfix_tables.md || true
echo "[Stage F] Done. Tables: $WORKDIR/ark/paper_tables/deadline_stage_f_budgetfix_tables.md"
