#!/usr/bin/env python3
"""Pairwise diagnostics for PAR-ARK deadline paper.

Reads two log directories with identical question JSON files, usually:
- off baseline logs
- full/PAR logs

Outputs a markdown summary plus machine-readable JSON.
No labels are used to choose the method; oracle numbers are clearly marked diagnostic-only.
"""
from __future__ import annotations

import argparse
import json
import math
from collections import Counter, defaultdict
from pathlib import Path
from statistics import mean
from typing import Any


def load_json(path: Path) -> dict[str, Any] | None:
    try:
        return json.loads(path.read_text())
    except Exception as e:
        print(f"BAD_JSON {path}: {e}")
        return None


def ranked_answers(d: dict[str, Any], max_agents: int = 1) -> list[int]:
    flat: list[int] = []
    for tr in d.get("trajectories", [])[:max_agents]:
        flat.extend(int(x) for x in tr.get("agent_answer_indices", []) if str(x).lstrip("-").isdigit())
    counts = Counter(flat)
    first_seen: dict[int, int] = {}
    for i, idx in enumerate(flat):
        first_seen.setdefault(idx, i)
    return sorted(counts.keys(), key=lambda x: (-counts[x], first_seen[x]))


def metrics_for_ranked(ranked: list[int], gold: set[int]) -> dict[str, float]:
    rr = 0.0
    for rank, idx in enumerate(ranked, 1):
        if idx in gold:
            rr = 1.0 / rank
            break
    denom = max(1, len(gold))
    return {
        "hit1": float(bool(ranked and ranked[0] in gold)),
        "hit5": float(bool(gold.intersection(ranked[:5]))),
        "r10": len(gold.intersection(ranked[:10])) / denom,
        "r20": len(gold.intersection(ranked[:20])) / denom,
        "rall": len(gold.intersection(ranked)) / denom,
        "mrr": rr,
    }


def metrics_for_log(d: dict[str, Any], max_agents: int = 1) -> dict[str, float]:
    gold = set(int(x) for x in d.get("answer_indices", []))
    return metrics_for_ranked(ranked_answers(d, max_agents=max_agents), gold)


def trace_summary(d: dict[str, Any], max_agents: int = 1) -> dict[str, float]:
    trajs = d.get("trajectories", [])[:max_agents]
    out = {
        "global": 0.0,
        "neigh": 0.0,
        "zero": 0.0,
        "repeat": 0.0,
        "events": 0.0,
        "steps": 0.0,
        "time": float(d.get("time_taken") or 0.0),
    }
    for tr in trajs:
        ts = tr.get("par_trace_summary", {}) or {}
        tools = ts.get("tool_counts", {}) or {}
        out["global"] += float(tools.get("search_in_graph", 0))
        out["neigh"] += float(tools.get("search_in_neighborhood", 0))
        out["zero"] += float(ts.get("zero_result_calls", 0))
        out["repeat"] += float(ts.get("repeated_calls", 0))
        out["events"] += float(ts.get("num_events", 0))
        out["steps"] += float(tr.get("steps", 0))
    n = max(1, len(trajs))
    for k in ["global", "neigh", "zero", "repeat", "events", "steps"]:
        out[k] /= n
    return out


def average(rows: list[dict[str, float]], key: str) -> float:
    vals = [r[key] for r in rows if key in r and not math.isnan(r[key])]
    return mean(vals) if vals else float("nan")


def combine_off_first(off_ranked: list[int], par_ranked: list[int], keep_off_prefix: int) -> list[int]:
    out: list[int] = []
    seen: set[int] = set()
    for x in off_ranked[:keep_off_prefix]:
        if x not in seen:
            out.append(x); seen.add(x)
    for x in par_ranked:
        if x not in seen:
            out.append(x); seen.add(x)
    for x in off_ranked[keep_off_prefix:]:
        if x not in seen:
            out.append(x); seen.add(x)
    return out


def fmt(x: float) -> str:
    if math.isnan(x):
        return "nan"
    return f"{x:.4f}"


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--off_dir", required=True)
    ap.add_argument("--full_dir", required=True)
    ap.add_argument("--out", required=True)
    ap.add_argument("--max_agents", type=int, default=1)
    args = ap.parse_args()

    off_dir = Path(args.off_dir)
    full_dir = Path(args.full_dir)
    off_files = {p.stem: p for p in off_dir.glob("*.json") if p.name != "metrics_summary.json"}
    full_files = {p.stem: p for p in full_dir.glob("*.json") if p.name != "metrics_summary.json"}
    qids = sorted(set(off_files).intersection(full_files))

    per_off: list[dict[str, float]] = []
    per_full: list[dict[str, float]] = []
    per_oracle: list[dict[str, float]] = []
    per_trace: list[dict[str, float]] = []
    win_loss = defaultdict(int)
    fusion_by_k: dict[int, list[dict[str, float]]] = {k: [] for k in [1, 3, 5, 10, 20]}
    conditional = defaultdict(list)

    for qid in qids:
        od = load_json(off_files[qid])
        fd = load_json(full_files[qid])
        if od is None or fd is None:
            continue
        om = metrics_for_log(od, args.max_agents)
        fm = metrics_for_log(fd, args.max_agents)
        per_off.append(om)
        per_full.append(fm)
        if fm["mrr"] > om["mrr"]:
            win_loss["full_mrr_win"] += 1
        elif fm["mrr"] < om["mrr"]:
            win_loss["full_mrr_loss"] += 1
        else:
            win_loss["full_mrr_tie"] += 1
        if fm["hit1"] > om["hit1"]:
            win_loss["full_hit1_win"] += 1
        elif fm["hit1"] < om["hit1"]:
            win_loss["full_hit1_loss"] += 1
        else:
            win_loss["full_hit1_tie"] += 1

        # Diagnostic-only oracle: choose the better of off/full after seeing labels.
        per_oracle.append(fm if fm["mrr"] >= om["mrr"] else om)

        gold = set(int(x) for x in od.get("answer_indices", []))
        orank = ranked_answers(od, args.max_agents)
        frank = ranked_answers(fd, args.max_agents)
        for k in fusion_by_k:
            fusion_by_k[k].append(metrics_for_ranked(combine_off_first(orank, frank, k), gold))

        ts = trace_summary(fd, args.max_agents)
        per_trace.append(ts)
        conditional["zero>=1" if ts["zero"] >= 1 else "zero=0"].append(fm["mrr"] - om["mrr"])
        conditional["repeat>=1" if ts["repeat"] >= 1 else "repeat=0"].append(fm["mrr"] - om["mrr"])

    def avg_metrics(rows: list[dict[str, float]]) -> dict[str, float]:
        return {k: average(rows, k) for k in ["hit1", "hit5", "r10", "r20", "rall", "mrr"]}

    off_avg = avg_metrics(per_off)
    full_avg = avg_metrics(per_full)
    oracle_avg = avg_metrics(per_oracle)
    fusion_avg = {k: avg_metrics(v) for k, v in fusion_by_k.items()}
    trace_avg = {k: average(per_trace, k) for k in ["global", "neigh", "zero", "repeat", "events", "steps", "time"]}
    cond_avg = {k: (mean(v) if v else float("nan"), len(v)) for k, v in conditional.items()}

    lines: list[str] = []
    lines.append("# Pair Diagnostics")
    lines.append("")
    lines.append(f"off_dir: `{off_dir}`")
    lines.append(f"full_dir: `{full_dir}`")
    lines.append(f"paired_n: **{len(per_off)}**; off_only={len(set(off_files)-set(full_files))}; full_only={len(set(full_files)-set(off_files))}")
    lines.append("")
    lines.append("## Main paired metrics")
    lines.append("")
    lines.append("| system | Hit@1 | Hit@5 | R@10 | R@20 | R@all | MRR |")
    lines.append("|---|---:|---:|---:|---:|---:|---:|")
    for name, avg in [("off", off_avg), ("full", full_avg), ("delta full-off", {k: full_avg[k]-off_avg[k] for k in off_avg}), ("oracle diagnostic upper bound", oracle_avg)]:
        lines.append(f"| {name} | {fmt(avg['hit1'])} | {fmt(avg['hit5'])} | {fmt(avg['r10'])} | {fmt(avg['r20'])} | {fmt(avg['rall'])} | {fmt(avg['mrr'])} |")
    lines.append("")
    lines.append("## Full-vs-off paired wins/losses")
    lines.append("")
    lines.append("| comparison | wins | ties | losses |")
    lines.append("|---|---:|---:|---:|")
    lines.append(f"| MRR | {win_loss['full_mrr_win']} | {win_loss['full_mrr_tie']} | {win_loss['full_mrr_loss']} |")
    lines.append(f"| Hit@1 | {win_loss['full_hit1_win']} | {win_loss['full_hit1_tie']} | {win_loss['full_hit1_loss']} |")
    lines.append("")
    lines.append("## Full-mode trace statistics")
    lines.append("")
    lines.append("| global | neighborhood | zero-result | repeated | events | steps | time(s) |")
    lines.append("|---:|---:|---:|---:|---:|---:|---:|")
    lines.append(f"| {fmt(trace_avg['global'])} | {fmt(trace_avg['neigh'])} | {fmt(trace_avg['zero'])} | {fmt(trace_avg['repeat'])} | {fmt(trace_avg['events'])} | {fmt(trace_avg['steps'])} | {fmt(trace_avg['time'])} |")
    lines.append("")
    lines.append("## Conditional MRR delta by trace failure feature")
    lines.append("")
    lines.append("| bucket | n | mean(full MRR - off MRR) |")
    lines.append("|---|---:|---:|")
    for k, (v, n) in sorted(cond_avg.items()):
        lines.append(f"| {k} | {n} | {fmt(v)} |")
    lines.append("")
    lines.append("## Diagnostic fusion sweep, not a claimed method unless k is chosen on validation only")
    lines.append("")
    lines.append("| fusion | Hit@1 | Hit@5 | R@20 | R@all | MRR |")
    lines.append("|---|---:|---:|---:|---:|---:|")
    for k, avg in fusion_avg.items():
        lines.append(f"| off-first-{k}-then-full | {fmt(avg['hit1'])} | {fmt(avg['hit5'])} | {fmt(avg['r20'])} | {fmt(avg['rall'])} | {fmt(avg['mrr'])} |")
    lines.append("")
    lines.append("Interpretation note: the oracle row is an upper bound for future routers; do not report it as a deployable method. The fusion sweep is exploratory unless the prefix k was fixed on validation before evaluating test.")

    out = Path(args.out)
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text("\n".join(lines))
    summary = {
        "paired_n": len(per_off),
        "off_avg": off_avg,
        "full_avg": full_avg,
        "delta_full_minus_off": {k: full_avg[k]-off_avg[k] for k in off_avg},
        "oracle_diagnostic_upper_bound": oracle_avg,
        "win_loss": dict(win_loss),
        "trace_avg": trace_avg,
        "conditional_mrr_delta": {k: {"mean_delta": v, "n": n} for k, (v, n) in cond_avg.items()},
        "fusion_sweep": fusion_avg,
        "off_dir": str(off_dir),
        "full_dir": str(full_dir),
    }
    out.with_suffix(".json").write_text(json.dumps(summary, indent=2))
    print(f"wrote {out}")
    print(f"wrote {out.with_suffix('.json')}")


if __name__ == "__main__":
    main()
