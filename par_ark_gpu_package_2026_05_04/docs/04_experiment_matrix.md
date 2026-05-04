# Experiment Matrix

## Metrics

Use ARK/STaRK metrics:

- Hit@1
- Hit@5
- Recall@10
- Recall@20
- MRR
- runtime/tool metrics: steps, global searches, neighborhood searches, repeated calls, zero-result calls, selected answers, wall time

## Datasets and splits

Primary:

- `prime`, split `test`
- `mag`, split `test`
- `amazon`, split `test`

Validation/tuning:

- use `--limit 100` or `--limit 200` on `val` if the repository split exists;
- use `test` only once for final numbers.

Optional:

- `human_generated_eval` through `stark-qa`, if ARK's local data layout contains the split or the agent exports it.
- PBR/PersonaBench mini-run if making a real personalization claim.

## Model tiers

### Tier 0: smoke

- model: Qwen3-8B
- graph: prime
- split: test
- limit: 20
- agents: 1
- max steps: 12

### Tier 1: validation ablations

- model: Qwen3-14B
- graphs: prime, mag, amazon
- split: val if available, otherwise test with `--limit 100` only for tuning
- agents: 1
- max steps: 12, 16
- variants: ARK-local, profile, trace, full

### Tier 2: final local teacher

- model: Qwen3-30B-A3B-Instruct-2507
- graphs: prime, mag, amazon
- split: test
- agents: 1 and optionally 3 sequential
- max steps: chosen from validation, usually 16
- variants: ARK-local and PAR-ARK-full

### Tier 3 optional: rerank

- stop controller vLLM;
- rerank candidate lists from Tier 2;
- report separately as `PAR-ARK-full+rerank`.

### Tier 4 optional: distillation

- generate trajectories from Qwen3-30B-A3B PAR-ARK on train/val subsets;
- LoRA fine-tune Qwen3-8B;
- evaluate student on test.

## Minimal paper table set

1. Main quality table: Hit@1, Hit@5, Recall@20, MRR for all three STaRK datasets.
2. Same-backbone ablation table: ARK-local vs profile vs trace vs full.
3. Budget table: steps/tool calls/runtime/repeated calls/zero-result repairs.
4. Case study: 3 examples showing trace repair changed action sequence.
5. Optional student table: Qwen3-8B base vs self-distilled Qwen3-8B.
