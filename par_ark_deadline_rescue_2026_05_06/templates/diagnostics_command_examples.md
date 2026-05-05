# Diagnostics Command Examples

Set these after Stage E, adjusting LIMIT if needed.

```bash
export WORKDIR=${WORKDIR:-$HOME/par_ark_workspace}
export MODEL_SHORT=Qwen3-30B-A3B-Instruct-2507
export LIMIT=300
export STEPS=16

for GRAPH in prime mag amazon; do
  python /path/to/par_ark_deadline_rescue_2026_05_06/scripts/21_pair_diagnostics.py \
    --off_dir "$WORKDIR/ark/data/experiments/$GRAPH/graph_explorer_${MODEL_SHORT}_deadline_off_q30b_limit${LIMIT}_s${STEPS}/test" \
    --full_dir "$WORKDIR/ark/data/experiments/$GRAPH/graph_explorer_${MODEL_SHORT}_par_full_deadline_full_q30b_limit${LIMIT}_s${STEPS}/test" \
    --out "$WORKDIR/ark/paper_tables/${GRAPH}_deadline_pair_diagnostics.md"
done
```

For B2 pilot from existing RESULTS, inspect the exact experiment names under:

```bash
find "$WORKDIR/ark/data/experiments" -path '*metrics_summary.json' | sort
```

Then pass the matching `off_dir` and `full_dir` to `21_pair_diagnostics.py`.
