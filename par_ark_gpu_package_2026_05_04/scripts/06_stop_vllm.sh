#!/usr/bin/env bash
set -euo pipefail
pkill -f "vllm serve" || true
pkill -f "vllm.entrypoints" || true
sleep 5
nvidia-smi || true
