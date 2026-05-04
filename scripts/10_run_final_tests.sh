#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib_parark_runtime.sh"
STAGE=10_run_final_tests
stage_status "$STAGE" "RUNNING" "Qwen3-30B-A3B final tests"
cd "$WORKDIR/ark"
export VLLM_PORT=${VLLM_PORT:-8000}
MODEL="Qwen/Qwen3-30B-A3B-Instruct-2507"
SPLIT=${SPLIT:-test}
MAX_STEPS=${MAX_STEPS:-16}
AGENTS=${AGENTS:-1}
curl -sSf "http://localhost:${VLLM_PORT}/v1/models" >/dev/null
# First run matched local ARK baseline, then PAR-ARK full.
for GRAPH in prime mag amazon; do
  heartbeat "$STAGE" "graph=$GRAPH mode=off split=$SPLIT agents=$AGENTS steps=$MAX_STEPS"
  uv run python par_main.py --graph_name "$GRAPH" --model_name "$MODEL" --split "$SPLIT" --number_of_agents "$AGENTS" --max_steps "$MAX_STEPS" --par_mode off --run_tag final_arklocal_q30b_a${AGENTS}
  checkpoint "$STAGE" "generation graph=$GRAPH mode=off"
  uv run python par_eval.py --graph_name "$GRAPH" --model_name "$MODEL" --split "$SPLIT" --run_tag final_arklocal_q30b_a${AGENTS} --par_mode off --max_agents "$AGENTS"
  checkpoint "$STAGE" "eval graph=$GRAPH mode=off"
  heartbeat "$STAGE" "graph=$GRAPH mode=full split=$SPLIT agents=$AGENTS steps=$MAX_STEPS"
  uv run python par_main.py --graph_name "$GRAPH" --model_name "$MODEL" --split "$SPLIT" --number_of_agents "$AGENTS" --max_steps "$MAX_STEPS" --par_mode full --run_tag final_parark_q30b_a${AGENTS}
  checkpoint "$STAGE" "generation graph=$GRAPH mode=full"
  uv run python par_eval.py --graph_name "$GRAPH" --model_name "$MODEL" --split "$SPLIT" --run_tag final_parark_q30b_a${AGENTS} --par_mode full --max_agents "$AGENTS"
  checkpoint "$STAGE" "eval graph=$GRAPH mode=full"
  require_disk_budget
done
stage_status "$STAGE" "SUCCEEDED" "final tests complete"
