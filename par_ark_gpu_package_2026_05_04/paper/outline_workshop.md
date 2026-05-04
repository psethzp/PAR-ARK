# PAR-ARK Workshop Paper Outline

## Title
PAR-ARK: Open-Weight Profile-Conditioned Trace-Aware Retrieval for Text-Rich Knowledge Graphs

## Abstract skeleton
Adaptive retrieval over text-rich knowledge graphs requires both broad entity discovery and multi-hop relational exploration. Recent ARK-style agents improve this breadth-depth tradeoff, but their strongest results rely on closed LLM backbones and the retrieval policy is not explicitly conditioned on query/user profiles or trace-level failure signals. We introduce PAR-ARK, a GPU-local extension of ARK that adds profile-conditioned action priors, trace-state evidence sufficiency, and repair hints for failed or wasteful tool calls. On STaRK-Amazon, STaRK-MAG, and STaRK-PRIME, PAR-ARK improves same-backbone open-weight ARK under matched compute while reducing repeated or zero-result graph actions. We release reproducible scripts for Qwen3-14B and Qwen3-30B-A3B on 1–2 NVIDIA L40 GPUs.

## 1 Introduction
- STaRK problem: retrieval over textual + relational KBs.
- ARK shows agentic breadth-depth retrieval is strong.
- Gap: closed-model dependence, no explicit profile-before-retrieval, weak trace repair.
- Our contribution: PCAP + TESR + local GPU execution.

## 2 Related Work
- STaRK, KAR, mFAR, MoR, GraphFlow, AvaTaR, AF-Retriever.
- ARK as direct base.
- Personalized retrieval / PBR.
- Open-weight tool-using models.

## 3 Method
- ARK recap: global search + neighborhood exploration.
- PCAP profile JSON.
- TESR trace events and repair hints.
- Sequential multi-agent aggregation to avoid GPU OOM.
- Offline reranking and optional distillation.

## 4 Experiments
- Datasets: STaRK-Amazon/MAG/PRIME.
- Metrics: Hit@1, Hit@5, Recall@20, MRR, tool budget.
- Models: Qwen3-14B, Qwen3-30B-A3B.
- Baselines: ARK-local same backbone; published ARK closed model as upper bound; published BM25/KAR/mFAR/MoR/GraphFlow/AvaTaR context.

## 5 Results
- Main table.
- Ablation table.
- Budget/failure table.
- Case studies.

## 6 Limitations
- Closed-model ARK may remain higher.
- STaRK has query profiles, not actual user personalization.
- Reranking cannot fix absent candidates.
- Hardware-specific latency.

## 7 Conclusion
- PAR-ARK is a reproducible path for local adaptive graph retrieval.
