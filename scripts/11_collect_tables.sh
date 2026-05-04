#!/usr/bin/env bash
set -euo pipefail
export WORKDIR=${WORKDIR:-$HOME/par_ark_workspace}
cd "$WORKDIR/ark"
mkdir -p paper_tables
uv run python scripts/make_par_tables.py --root data/experiments --out paper_tables/par_ark_tables.md || true
printf "Tables attempted at %s/ark/paper_tables/par_ark_tables.md\n" "$WORKDIR"
