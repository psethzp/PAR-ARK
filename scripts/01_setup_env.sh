#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib_parark_runtime.sh"
STAGE=01_setup_env
stage_status "$STAGE" "RUNNING" "installing uv/vLLM/stark dependencies"
require_disk_budget
cd "$WORKDIR/ark"
python3 -m pip install --user -U uv || true
python3 -m pip install --user -U huggingface_hub hf_transfer || true
export PATH="$HOME/.local/bin:$PATH"
UV_PYTHON=${UV_PYTHON:-3.11}
uv python install "$UV_PYTHON"
UV_NO_SYNC=0 uv sync --python "$UV_PYTHON"
uv pip install "vllm>=0.9.0" --torch-backend=auto
uv pip install stark-qa FlagEmbedding peft bitsandbytes accelerate sentence-transformers pandas polars pyarrow matplotlib pyyaml
uv pip install "numpy<2"
cat > .env <<'ENV'
# No GPT/OpenAI keys required for local Qwen runs.
VLLM_PORT=8000
ENV
uv run --no-sync python - <<'PY'
import importlib
for name in ["torch", "pandas", "stark_qa", "sentence_transformers"]:
    importlib.import_module(name)
print("core imports ok")
PY
checkpoint "$STAGE" "environment installed with UV_PYTHON=$UV_PYTHON"
stage_status "$STAGE" "SUCCEEDED" "Environment installed"
printf "Environment installed. Activate via: cd %s/ark && source .venv/bin/activate\n" "$WORKDIR"
