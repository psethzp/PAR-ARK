#!/usr/bin/env bash
set -euo pipefail

export WORKDIR=${WORKDIR:-$HOME/par_ark_workspace}
cd "$WORKDIR/ark"

MODEL=${MODEL:-Qwen/Qwen3-30B-A3B-Instruct-2507}
SPLIT=${SPLIT:-test}
LIMIT=${LIMIT:-300}
MAX_STEPS=${MAX_STEPS:-16}
AGENTS=${AGENTS:-1}
SHARD_NAME=${SHARD_NAME:-shard}

if [ -z "${VLLM_PORT:-}" ]; then
  echo "[Stage E shard] ERROR: VLLM_PORT must be set for this shard."
  exit 2
fi

if [ -z "${CELLS:-}" ]; then
  echo "[Stage E shard] ERROR: CELLS must be set, e.g. CELLS='prime:off mag:full amazon:off'."
  exit 2
fi

printf '\n[Stage E shard:%s] split=%s limit=%s steps=%s model=%s vllm_port=%s\n' \
  "$SHARD_NAME" "$SPLIT" "$LIMIT" "$MAX_STEPS" "$MODEL" "$VLLM_PORT"
printf '[Stage E shard:%s] cells=%s\n\n' "$SHARD_NAME" "$CELLS"

for SPEC in $CELLS; do
  GRAPH=${SPEC%%:*}
  MODE=${SPEC##*:}
  if [ "$GRAPH" = "$SPEC" ] || [ -z "$GRAPH" ] || [ -z "$MODE" ]; then
    echo "[Stage E shard:$SHARD_NAME] Bad cell spec: $SPEC"
    exit 2
  fi

  TAG="deadline_${MODE}_q30b_limit${LIMIT}_s${MAX_STEPS}"
  echo "[Stage E shard:$SHARD_NAME] graph=$GRAPH mode=$MODE tag=$TAG port=$VLLM_PORT"

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

mkdir -p paper_tables
uv run python scripts/make_par_tables.py --out "paper_tables/deadline_stage_e_tables_${SHARD_NAME}.md" || true
echo "[Stage E shard:$SHARD_NAME] Done. Tables: $WORKDIR/ark/paper_tables/deadline_stage_e_tables_${SHARD_NAME}.md"
