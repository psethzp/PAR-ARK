#!/usr/bin/env bash
set -euo pipefail
export WORKDIR=${WORKDIR:-$HOME/par_ark_workspace}
cd "$WORKDIR/ark"
python3 -m pip install --user -U uv || true
python3 -m pip install --user -U huggingface_hub hf_transfer || true
export PATH="$HOME/.local/bin:$PATH"
uv sync
uv pip install "vllm>=0.9.0" --torch-backend=auto
uv pip install stark-qa FlagEmbedding peft bitsandbytes accelerate sentence-transformers pandas polars pyarrow matplotlib pyyaml
cat > .env <<'ENV'
# No GPT/OpenAI keys required for local Qwen runs.
VLLM_PORT=8000
ENV
printf "Environment installed. Activate via: cd %s/ark && source .venv/bin/activate\n" "$WORKDIR"
