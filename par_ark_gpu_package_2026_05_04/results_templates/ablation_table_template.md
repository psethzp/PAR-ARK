# Ablation Table Template

| Variant | Backbone | PCAP | TESR | Rerank | Hit@1 | Hit@5 | R@20 | MRR | Steps | Global | Neighborhood | Zero-result | Repeated |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| ARK-local | Qwen3-14B | no | no | no | | | | | | | | | |
| +Profile | Qwen3-14B | yes | no | no | | | | | | | | | |
| +Trace | Qwen3-14B | no | yes | no | | | | | | | | | |
| PAR-ARK-full | Qwen3-14B | yes | yes | no | | | | | | | | | |
| PAR-ARK-full+rerank | Qwen3-14B | yes | yes | yes | | | | | | | | | |
