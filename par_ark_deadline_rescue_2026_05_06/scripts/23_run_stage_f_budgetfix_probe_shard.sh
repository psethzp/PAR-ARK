#!/usr/bin/env bash
set -euo pipefail

export WORKDIR=${WORKDIR:-$HOME/par_ark_workspace}
cd "$WORKDIR/ark"

MODEL=${MODEL:-Qwen/Qwen3-30B-A3B-Instruct-2507}
SPLIT=${SPLIT:-test}
LIMIT=${LIMIT:-150}
MAX_STEPS=${MAX_STEPS:-8}
MAX_GLOBAL=${MAX_GLOBAL:-2}
MAX_NEIGH=${MAX_NEIGH:-3}
MAX_OBS=${MAX_OBS:-2500}
MAX_ANS=${MAX_ANS:-10}
AGENTS=${AGENTS:-1}
SHARD_NAME=${SHARD_NAME:-shard}

if [ -z "${VLLM_PORT:-}" ]; then
  echo "[Stage F shard] ERROR: VLLM_PORT must be set for this shard."
  exit 2
fi

if [ -z "${GRAPHS:-}" ]; then
  echo "[Stage F shard] ERROR: GRAPHS must be set, e.g. GRAPHS='prime mag'."
  exit 2
fi

printf '\n[Stage F shard:%s] split=%s limit=%s steps=%s global=%s neigh=%s obs=%s answers=%s vllm_port=%s\n\n' \
  "$SHARD_NAME" "$SPLIT" "$LIMIT" "$MAX_STEPS" "$MAX_GLOBAL" "$MAX_NEIGH" "$MAX_OBS" "$MAX_ANS" "$VLLM_PORT"

for GRAPH in $GRAPHS; do
  MODE=full
  TAG="deadline_budgetfix_q30b_limit${LIMIT}_s${MAX_STEPS}_g${MAX_GLOBAL}_n${MAX_NEIGH}_obs${MAX_OBS}"
  echo "[Stage F shard:$SHARD_NAME] graph=$GRAPH mode=$MODE tag=$TAG port=$VLLM_PORT"

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
uv run python scripts/make_par_tables.py --out "paper_tables/deadline_stage_f_budgetfix_tables_${SHARD_NAME}.md" || true
echo "[Stage F shard:$SHARD_NAME] Done. Tables: $WORKDIR/ark/paper_tables/deadline_stage_f_budgetfix_tables_${SHARD_NAME}.md"
