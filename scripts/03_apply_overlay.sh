#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib_parark_runtime.sh"
STAGE=03_apply_overlay
stage_status "$STAGE" "RUNNING" "applying PAR-ARK overlay"
# Run from inside the unpacked package directory or set PACKAGE_DIR.
cd "$WORKDIR/ark"
python "$PACKAGE_DIR/patches/apply_par_ark_overlay.py" --ark-root "$WORKDIR/ark"
uv run python -m py_compile par_main.py par_eval.py src/agents/graph_explorer/par_profile.py src/agents/graph_explorer/par_trace.py src/agents/graph_explorer/par_graph_explorer.py scripts/make_par_tables.py scripts/offline_rerank_qwen3.py
checkpoint "$STAGE" "overlay applied and compiled"
stage_status "$STAGE" "SUCCEEDED" "overlay ready"
