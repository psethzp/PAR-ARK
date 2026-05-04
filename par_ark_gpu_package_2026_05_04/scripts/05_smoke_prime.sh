#!/usr/bin/env bash
set -euo pipefail
export WORKDIR=${WORKDIR:-$HOME/par_ark_workspace}
cd "$WORKDIR/ark"
export VLLM_PORT=${VLLM_PORT:-8000}
uv run python par_main.py --graph_name prime --model_name Qwen/Qwen3-8B --split test --limit 20 --number_of_agents 1 --max_steps 12 --par_mode full --run_tag smoke_qwen3_8b
uv run python par_eval.py --graph_name prime --model_name Qwen/Qwen3-8B --split test --run_tag smoke_qwen3_8b --par_mode full --max_agents 1
