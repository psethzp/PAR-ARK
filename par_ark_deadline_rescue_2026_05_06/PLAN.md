Based on your attached `RESULTS.md`: **yes, you have enough for an ICML workshop paper only if you pivot to a failure/diagnostic paper.** You do **not** currently have enough for a positive “we beat SOTA / A* main” paper.

Your strongest target is now **FAGEN @ ICML 2026: Failure Modes in Agentic AI**, not GFM as the main target. FAGEN explicitly asks for reproducible failures, trace diagnostics, mitigation/repair evidence, and says well-documented negative results are in scope; its deadline is **May 8, 2026 AoE** and notification is **May 15**. ([fagen-workshop.github.io][1])

I made the updated deadline-rescue package here: [Download the May 6/7 PAR-ARK rescue package](sandbox:/mnt/data/par_ark_deadline_rescue_2026_05_06.zip).

---

## 1. Honest verdict on current results

### Not enough for this claim

> “PAR-ARK improves SOTA adaptive KG retrieval.”

Your own results show the opposite.

On **Qwen3-14B validation**, `off` is best on average:

| Mode | Steps |  Avg Hit@1 |  Avg Hit@5 |   Avg R@20 |    Avg MRR |
| ---- | ----: | ---------: | ---------: | ---------: | ---------: |
| off  |    12 | **0.3333** | **0.5100** | **0.4252** | **0.4087** |
| full |    12 |     0.2579 |     0.3951 |     0.3036 |     0.3141 |
| full |    16 |     0.2567 |     0.3900 |     0.2998 |     0.3103 |

On **Qwen3-30B-A3B pilot**, `full` loses on every graph:

| Graph  | Off MRR | Full MRR | Full - Off |
| ------ | ------: | -------: | ---------: |
| prime  |  0.3502 |   0.2670 |    -0.0832 |
| mag    |  0.8105 |   0.4797 |    -0.3308 |
| amazon |  0.6600 |   0.5150 |    -0.1450 |

So do **not** write a “new method beats baseline” paper.

### Enough for this claim

> “Adaptive KG retrieval agents can fail under local open-weight controllers; trace metrics reveal why.”

That is a valid workshop paper. In fact, it fits FAGEN very well because the workshop’s stated scope includes trace-level diagnostics, reproducible triggers, mitigation strategies, and careful negative results. ([fagen-workshop.github.io][1])

The paper title should be:

> **When Adaptive Knowledge-Graph Retrieval Fails: Trace Diagnostics for Local LLM Agents on STaRK**

---

## 2. Why not full Stage C or full reranking now?

Do **not** run the unchanged full Stage C. It is the wrong use of your remaining time.

Your B2 pilot processed roughly 299 usable question-runs. Using the per-question `TimeMean(s)` values:

```text
prime/off   49 × 9.435  = 462 s
prime/full  50 × 7.444  = 372 s
mag/off     49 × 12.483 = 612 s
mag/full    50 × 6.951  = 348 s
amazon/off  50 × 10.251 = 513 s
amazon/full 50 × 6.333  = 317 s

Total measured model time ≈ 2,624 s = 43.7 min
Observed wall time ≈ 85 min
Practical overhead factor ≈ 1.9–2.0×
```

So your practical speed is about:

```text
85 min / 299 ≈ 17 s per question-run wall-clock
```

Full Stage C is about **7,106 question-runs**:

```text
7,106 × 17 s ≈ 120,802 s ≈ 33.6 hours
```

That matches your 35–38 hour estimate. It is too risky before a May 8 deadline.

Also skip full Stage D reranking. It is not central to the failure paper, and it risks burning 6–18 hours on a result that may not change the story.

---

## 3. New one-day plan

### Goal

Produce a paper that is robust even if every new number is bad.

The paper’s core message:

> Profile/trace-conditioned adaptive retrieval looks reasonable, but under local Qwen controllers it causes over-exploration, zero-result tool calls, repeated calls, and worse ranking. Final metrics show the drop; traces explain the mechanism.

STaRK is the right benchmark because it is explicitly for retrieval over textual and relational knowledge bases across product search, academic paper search, and biomedicine; ARK also uses STaRK and reports Hit@1, Hit@5, Recall@20, and MRR. ([GitHub][2])

ARK remains the reference baseline: it uses global BM25 search and one-hop neighborhood exploration, and its repo reports strong STaRK results, including 59.1% average Hit@1 and 67.4 average MRR for the full ARK setup. ([GitHub][3])

---

## 4. What to run now

Use the rescue package:

[Download the May 6/7 PAR-ARK rescue package](sandbox:/mnt/data/par_ark_deadline_rescue_2026_05_06.zip)

Unzip it, then run:

```bash
unzip par_ark_deadline_rescue_2026_05_06.zip
cd par_ark_deadline_rescue_2026_05_06
export WORKDIR=$HOME/par_ark_workspace
```

Start the 30B server using your existing script:

```bash
cd $WORKDIR/ark
bash scripts/09_serve_qwen3_30b_a3b_tp2.sh
```

Then run the new subset experiment:

```bash
cd /path/to/par_ark_deadline_rescue_2026_05_06
LIMIT=300 bash scripts/18_run_stage_e_30b_subset.sh
```

This runs:

```text
graphs: prime, mag, amazon
modes: off, full
model: Qwen3-30B-A3B
split: test
limit: 300 per graph/mode
total: 1,800 question-runs
ETA: about 8–9 hours on one TP2 server
```

If it is already late, use:

```bash
LIMIT=200 bash scripts/18_run_stage_e_30b_subset.sh
```

That should be around 5.5–6 hours. If there are only a few hours left:

```bash
LIMIT=150 bash scripts/18_run_stage_e_30b_subset.sh
```

That is the emergency minimum.

---

## 5. Run the budget-fix probe

After Stage E starts or finishes, run this if time remains:

```bash
LIMIT=150 bash scripts/19_run_stage_f_budgetfix_probe.sh
```

This runs `full` again with stricter settings:

```text
max_steps = 8
max_global_searches = 2
max_neighborhood_searches = 3
max_observation_chars = 2500
max_answers = 10
```

This is **not** expected to magically beat `off`. Its purpose is to support the FAGEN-style claim:

> “A stricter budget reduces some failure behavior, but retrieval quality trade-offs remain.”

That is a useful “verified fix / measured trade-off” result, even if the fix is only partially successful.

---

## 6. Run diagnostics

The rescue package includes:

```bash
scripts/21_pair_diagnostics.py
```

It compares paired `off` and `full` logs and produces:

* paired `off` vs `full` metrics;
* full-vs-off win/tie/loss counts;
* average global searches, neighborhood searches, zero-result calls, repeated calls;
* conditional MRR deltas when zero/repeat events happen;
* oracle diagnostic upper bound, clearly marked as not a method;
* fusion sweep, clearly marked exploratory unless chosen on validation.

Example:

```bash
export WORKDIR=$HOME/par_ark_workspace
export MODEL_SHORT=Qwen3-30B-A3B-Instruct-2507
export LIMIT=300
export STEPS=16

python scripts/21_pair_diagnostics.py \
  --off_dir "$WORKDIR/ark/data/experiments/prime/graph_explorer_${MODEL_SHORT}_deadline_off_q30b_limit${LIMIT}_s${STEPS}/test" \
  --full_dir "$WORKDIR/ark/data/experiments/prime/graph_explorer_${MODEL_SHORT}_par_full_deadline_full_q30b_limit${LIMIT}_s${STEPS}/test" \
  --out "$WORKDIR/ark/paper_tables/prime_deadline_pair_diagnostics.md"
```

Repeat for `mag` and `amazon`.

---

## 7. Paper structure for May 8

Use the outline in the package:

```text
paper/FAGEN_PAPER_OUTLINE.md
```

The submission should be framed as follows.

### Title

**When Adaptive Knowledge-Graph Retrieval Fails: Trace Diagnostics for Local LLM Agents on STaRK**

### Main claim

Adaptive KG retrieval is not automatically better under local open-weight controllers. In your setup, adding profile/trace control made retrieval faster but worse, and trace metrics reveal the failure mechanism.

### Contributions

1. **Reproducible trigger:** enabling profile/trace control in an ARK-style local KG retrieval agent.
2. **Trace diagnostics:** global calls, neighborhood calls, zero-result calls, repeated calls, step counts, time, and paired rank deltas.
3. **Empirical finding:** Qwen3-14B and Qwen3-30B-A3B both show that the complete intervention underperforms the local/off baseline.
4. **Mitigation probe:** stricter budgets quantify whether failure can be reduced and what it costs.
5. **Practical lesson:** final-score-only evaluation hides the process failure; trace-level evaluation is necessary.

This directly matches FAGEN’s call for trace diagnostics and negative results. ([fagen-workshop.github.io][1])

---

## 8. What not to claim

Do **not** claim:

* “PAR-ARK beats ARK.”
* “PAR-ARK beats SOTA.”
* “This is guaranteed to be accepted.”
* “Personalization improves STaRK.”
* “Reranking solves the issue,” unless you actually run it and it helps.

Do claim:

* “This is a diagnostic study of local adaptive KG retrieval.”
* “The intervention is a reproducible failure trigger.”
* “Trace metrics explain why the agent fails.”
* “Closed-model ARK remains a strong reference; local controllers do not inherit that behavior automatically.”

---

## 9. Venue choice

### Submit to FAGEN first

FAGEN is the best fit because it explicitly welcomes careful negative results, trace diagnostics, reproducible failures, and repair/mitigation evidence. Deadline: **May 8, 2026 AoE**. ([fagen-workshop.github.io][1])

### Secondary option: Foundation Models for Structured Data

FMSD also has a May 8 deadline and accepts short papers up to 4 pages, but it is a weaker fit unless you frame this as structured-data retrieval evaluation rather than agent failure. ([icml-structured-fm-workshop.github.io][4])

### Do not prioritize GFM unless Stage E unexpectedly improves

GFM has the right graph flavor and a May 8 deadline, but your current results are not a strong positive graph-foundation-model result. ([OpenReview][5])

---

## 10. Final package

Use this package now:

[Download the May 6/7 PAR-ARK rescue package](sandbox:/mnt/data/par_ark_deadline_rescue_2026_05_06.zip)

It contains:

```text
README_AGENT_START_HERE.md
docs/
  DECISION_MEMO.md
  ETA_AND_SETTINGS.md
  INPUT_RESULTS.md
  INPUT_RUNBOOK.md
paper/
  FAGEN_PAPER_OUTLINE.md
scripts/
  18_run_stage_e_30b_subset.sh
  19_run_stage_f_budgetfix_probe.sh
  20_run_optional_profile_probe.sh
  21_pair_diagnostics.py
templates/
  diagnostics_command_examples.md
```

The safest path is: **run Stage E subset, run diagnostics, write FAGEN paper, add Stage F if it finishes.** This gives you a real workshop submission even if the method remains negative.

[1]: https://fagen-workshop.github.io/ "Failure Modes in Agentic AI (FAGEN) | ICML 2026 Workshop"
[2]: https://github.com/snap-stanford/stark "GitHub - snap-stanford/stark: (NeurIPS D&B 2024) STaRK: Benchmarking LLM Retrieval on Textual and Relational Knowledge Bases · GitHub"
[3]: https://github.com/mims-harvard/ark "GitHub - mims-harvard/ark: Autonomous Knowledge Graph Exploration with Adaptive Breadth-Depth Retrieval · GitHub"
[4]: https://icml-structured-fm-workshop.github.io/call-for-papers/ " Call for Papers | Foundation Models for Structured Data "
[5]: https://openreview.net/group?id=ICML.cc%2F2026%2FWorkshop%2FGFM&referrer=%5BHomepage%5D%28%2F%29&utm_source=chatgpt.com "ICML 2026 Workshop GFM"
