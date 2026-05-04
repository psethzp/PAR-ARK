#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib_parark_runtime.sh"
STAGE=11_collect_tables
stage_status "$STAGE" "RUNNING" "collecting paper tables"
cd "$WORKDIR/ark"
mkdir -p paper_tables
uv run python scripts/make_par_tables.py --root data/experiments --out paper_tables/par_ark_tables.md
checkpoint "$STAGE" "tables written"
stage_status "$STAGE" "SUCCEEDED" "tables attempted at $WORKDIR/ark/paper_tables/par_ark_tables.md"
printf "Tables attempted at %s/ark/paper_tables/par_ark_tables.md\n" "$WORKDIR"
