#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib_parark_runtime.sh"
STAGE=09_serve_qwen3_30b_a3b_tp2
stage_status "$STAGE" "RUNNING" "starting vLLM Qwen3-30B-A3B on GPUs $PARARK_GPUS_2"
require_disk_budget
cd "$WORKDIR/ark"
export CUDA_VISIBLE_DEVICES=${CUDA_VISIBLE_DEVICES:-$PARARK_GPUS_2}
export VLLM_PORT=${VLLM_PORT:-8000}
checkpoint "$STAGE" "launching TP2 vLLM on CUDA_VISIBLE_DEVICES=$CUDA_VISIBLE_DEVICES"
uv run vllm serve Qwen/Qwen3-30B-A3B-Instruct-2507 \
  --served-model-name Qwen/Qwen3-30B-A3B-Instruct-2507 \
  --host 0.0.0.0 --port "$VLLM_PORT" \
  --dtype bfloat16 \
  --tensor-parallel-size 2 \
  --max-model-len 32768 \
  --max-num-seqs 1 \
  --gpu-memory-utilization 0.90 \
  --enable-auto-tool-choice \
  --tool-call-parser hermes
