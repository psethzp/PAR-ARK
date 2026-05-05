# PAR-ARK Deadline Rescue Package — May 6/7, 2026

This package is for a May 8 ICML workshop deadline. It assumes the existing workspace from the previous PAR-ARK package is already working:

- Workspace: `/home/ubuntu/par_ark_workspace`
- ARK repo: `/home/ubuntu/par_ark_workspace/ark`
- Overlay files already applied: `par_main.py`, `par_eval.py`, PAR prompt/trace/profile modules
- Available final model path: `Qwen/Qwen3-30B-A3B-Instruct-2507`
- vLLM server script already exists: `scripts/09_serve_qwen3_30b_a3b_tp2.sh`

## Hard decision

Do **not** run the unchanged full Stage C over all 7,106 questions. It is too slow and the pilot shows the full intervention underperforms the local/off baseline.

Pivot the paper to:

> **When Adaptive Knowledge-Graph Retrieval Fails: Trace Diagnostics for Local LLM Agents on STaRK**

Best target: **FAGEN / ICML 2026 Failure Modes in Agentic AI**.

This is a valid paper even if all new numbers are bad, because the contribution is a reproducible failure trigger, trace-level diagnosis, and a measured mitigation/compute trade-off.

## Must-run experiments before writing final tables

### 1. Start 30B-A3B server

From the original package directory or wherever the scripts are installed:

```bash
export WORKDIR=${WORKDIR:-$HOME/par_ark_workspace}
bash scripts/09_serve_qwen3_30b_a3b_tp2.sh
```

Wait until `/v1/models` is healthy.

### 2. Run Stage E subset, not full Stage C

Default is 300 questions per graph per mode: 3 graphs × 2 modes × 300 = 1,800 questions. On the pilot speed this is about 8–9 wall-clock hours on one TP2 server.

```bash
cd /path/to/par_ark_deadline_rescue_2026_05_06
LIMIT=300 bash scripts/18_run_stage_e_30b_subset.sh
```

If it is already late, use `LIMIT=200`. If you have only a few hours, use `LIMIT=150`. Do not go below 150 unless the run is failing.

### 3. Run Stage F budget-fix probe

This tests whether a stricter trace controller mitigates the damage. It is not expected to beat the baseline. It is useful either way.

```bash
LIMIT=150 bash scripts/19_run_stage_f_budgetfix_probe.sh
```

### 4. Run diagnostics after each graph or after all graphs

Use exact log directories printed by `par_main.py`. Example:

```bash
python scripts/21_pair_diagnostics.py \
  --off_dir "$WORKDIR/ark/data/experiments/prime/graph_explorer_Qwen3-30B-A3B-Instruct-2507_deadline_off_q30b_limit300_s16/test" \
  --full_dir "$WORKDIR/ark/data/experiments/prime/graph_explorer_Qwen3-30B-A3B-Instruct-2507_par_full_deadline_full_q30b_limit300_s16/test" \
  --out "$WORKDIR/ark/paper_tables/prime_pair_diagnostics.md"
```

Repeat for `mag` and `amazon`. The script writes a markdown table and JSON summary.

### 5. Make paper

Use `paper/FAGEN_PAPER_OUTLINE.md`. Fill in:

- Stage A validation table from `RESULTS.md`
- Stage B2 pilot table from `RESULTS.md`
- Stage E subset table if completed
- Stage F budget-fix table if completed
- Trace diagnostics from `21_pair_diagnostics.py`

## Claims that are allowed

Allowed:

- Local open-weight adaptive KG agents can fail even when they are faster and more “agentic”.
- Adding profile/trace hints caused over-exploration, zero-result calls, repeated calls, and loss of ranking quality in this setup.
- Final-score-only evaluation hides this failure; trace metrics explain it.
- Stricter budgets reduce cost/damage, but the trade-off is measurable and not free.
- Existing closed-model ARK remains the high-performing reference; this work analyzes local-model failure under the same benchmark family.

Forbidden:

- Do not claim PAR-ARK beats ARK or SOTA.
- Do not claim guaranteed acceptance.
- Do not hide negative results.
- Do not tune on test labels.
- Do not report oracle routing as a method; only call it diagnostic upper bound.
