#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib_parark_runtime.sh"
STAGE=05_smoke_prime
stage_status "$STAGE" "RUNNING" "PRIME smoke test"
cd "$WORKDIR/ark"
export VLLM_PORT=${VLLM_PORT:-8000}
curl -sSf "http://localhost:${VLLM_PORT}/v1/models" >/dev/null
uv run python par_main.py --graph_name prime --model_name Qwen/Qwen3-8B --split test --limit 20 --number_of_agents 1 --max_steps 12 --par_mode full --run_tag smoke_qwen3_8b
checkpoint "$STAGE" "smoke generation completed"
uv run python par_eval.py --graph_name prime --model_name Qwen/Qwen3-8B --split test --run_tag smoke_qwen3_8b --par_mode full --max_agents 1
checkpoint "$STAGE" "smoke eval completed"
stage_status "$STAGE" "SUCCEEDED" "smoke run complete"
