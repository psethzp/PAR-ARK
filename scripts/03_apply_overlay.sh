#!/usr/bin/env bash
set -euo pipefail
export WORKDIR=${WORKDIR:-$HOME/par_ark_workspace}
PACKAGE_DIR=${PACKAGE_DIR:-$(pwd)}
# Run from inside the unpacked package directory or set PACKAGE_DIR.
cd "$WORKDIR/ark"
python "$PACKAGE_DIR/patches/apply_par_ark_overlay.py" --ark-root "$WORKDIR/ark"
