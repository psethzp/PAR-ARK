# Optional Reranking and Self-Distillation

## Offline reranking

Use reranking only after retrieval is done. Stop controller vLLM first.

Recommended:

```bash
bash scripts/06_stop_vllm.sh
bash scripts/12_rerank_final_candidates.sh
```

Primary reranker: `Qwen/Qwen3-Reranker-8B` via `sentence_transformers.CrossEncoder`. This model is 8B and 32k context. Fallback: `BAAI/bge-reranker-v2-m3`, which is smaller and easier to deploy but weaker.

Report reranked results as an extra row, not as the core method unless the candidate-generation ablation is already good. Reranking cannot rescue retrieval if the gold nodes never enter the candidate set.

## Local self-distillation

ARK already supports label-free trajectory imitation into Qwen3-8B. In this GPU-only version, replace the GPT teacher with your best local `Qwen3-30B-A3B-Instruct-2507 + PAR-ARK-full` teacher.

Stage:

1. Run PAR-ARK-full Qwen3-30B-A3B on train/val subsets.
2. Save trajectories as normal ARK logs.
3. Adapt ARK `finetune.py` to read PAR logs or copy PAR logs into the expected trajectory directory.
4. Fine-tune Qwen3-8B with LoRA for one epoch, max length 16384.
5. Serve the merged Qwen3-8B model and evaluate on test.

Student claim:

> Self-distilled local student recovers X% of Qwen3-30B-A3B PAR-ARK Hit@1 with lower memory and latency.

Do not make student the main claim unless it beats Qwen3-8B ARK-local by a clear margin.
