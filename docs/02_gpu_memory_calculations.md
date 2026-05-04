# GPU Memory Calculations and No-OOM Policy

Hardware: NVIDIA L40, 48GB GDDR6 ECC per GPU.

## Formula

Approximate BF16 weight memory:

```
weights_GB ≈ parameters_B × 2 bytes
```

Approximate KV cache per active sequence:

```
KV_bytes ≈ 2 × num_layers × num_kv_heads × head_dim × bytes_per_element × max_context_tokens
```

For BF16, `bytes_per_element = 2`. Add 6–12GB for CUDA/vLLM overhead, fragmentation, temporary activations, token buffers, and concurrent requests. MoE models still store all parameters in memory; only compute activates a subset.

## Model memory table

| Model | BF16 weights GB | KV @8k GiB | KV @16k GiB | KV @32k GiB | KV @64k GiB | Safe placement |
|---|---:|---:|---:|---:|---:|---|
| Qwen3-8B | 16.4 | 1.12 | 2.25 | 4.50 | 9.00 | 1× L40 easy |
| Qwen3-14B | 29.6 | 1.25 | 2.50 | 5.00 | 10.00 | 1× L40 at 16k; 32k may fit but is tighter |
| Qwen3-30B-A3B-Instruct-2507 | 61.0 | 0.75 | 1.50 | 3.00 | 6.00 | 2× L40 TP2 BF16 at 32k |
| Qwen3-32B dense | 65.6 | 2.00 | 4.00 | 8.00 | 16.00 | risky on 2× L40 at 32k; avoid |

## No-OOM rules

1. Use one vLLM server at a time.
2. Do not load a reranker while the controller vLLM is running.
3. Do not run ARK agents in parallel on local Qwen unless explicitly testing throughput. Use sequential multi-agent trajectories and aggregate after.
4. Start with `--max-model-len 16384` for Qwen3-14B and `32768` for Qwen3-30B-A3B TP2.
5. Use `--max-num-seqs 1` for Qwen3-30B-A3B final jobs.
6. Keep `--gpu-memory-utilization 0.86` for Qwen3-14B and `0.90` for Qwen3-30B-A3B TP2.
7. If OOM happens, reduce in this order: `max_model_len`, `max_num_seqs`, `max_tokens`, `number_of_agents`, then model size.
8. Quantization is acceptable for ablations and efficiency claims, but final quality table should prefer BF16 Qwen3-30B-A3B TP2 if it fits.

## Why not load multiple models together?

Qwen3-30B-A3B BF16 needs about 61GB just for weights, so TP2 places roughly 30.5GB of weights on each L40 before KV/cache. Loading a separate reranker simultaneously would push one or both GPUs toward OOM. Run retrieval first, save candidate JSON, stop vLLM, then rerank offline.
