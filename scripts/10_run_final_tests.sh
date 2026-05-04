#!/usr/bin/env bash
set -euo pipefail
export WORKDIR=${WORKDIR:-$HOME/par_ark_workspace}
cd "$WORKDIR/ark"
export VLLM_PORT=${VLLM_PORT:-8000}
MODEL="Qwen/Qwen3-30B-A3B-Instruct-2507"
SPLIT=${SPLIT:-test}
MAX_STEPS=${MAX_STEPS:-16}
AGENTS=${AGENTS:-1}
# First run matched local ARK baseline, then PAR-ARK full.
for GRAPH in prime mag amazon; do
  uv run python par_main.py --graph_name "$GRAPH" --model_name "$MODEL" --split "$SPLIT" --number_of_agents "$AGENTS" --max_steps "$MAX_STEPS" --par_mode off --run_tag final_arklocal_q30b_a${AGENTS}
  uv run python par_eval.py --graph_name "$GRAPH" --model_name "$MODEL" --split "$SPLIT" --run_tag final_arklocal_q30b_a${AGENTS} --par_mode off --max_agents "$AGENTS"
  uv run python par_main.py --graph_name "$GRAPH" --model_name "$MODEL" --split "$SPLIT" --number_of_agents "$AGENTS" --max_steps "$MAX_STEPS" --par_mode full --run_tag final_parark_q30b_a${AGENTS}
  uv run python par_eval.py --graph_name "$GRAPH" --model_name "$MODEL" --split "$SPLIT" --run_tag final_parark_q30b_a${AGENTS} --par_mode full --max_agents "$AGENTS"
done
