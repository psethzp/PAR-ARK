#!/usr/bin/env bash
set -euo pipefail
export WORKDIR=${WORKDIR:-$HOME/par_ark_workspace}
cd "$WORKDIR/ark"
export CUDA_VISIBLE_DEVICES=${CUDA_VISIBLE_DEVICES:-0}
export VLLM_PORT=${VLLM_PORT:-8000}
uv run vllm serve Qwen/Qwen3-8B \
  --served-model-name Qwen/Qwen3-8B \
  --host 0.0.0.0 --port "$VLLM_PORT" \
  --dtype bfloat16 \
  --max-model-len 16384 \
  --max-num-seqs 1 \
  --gpu-memory-utilization 0.82 \
  --enable-auto-tool-choice \
  --tool-call-parser hermes
