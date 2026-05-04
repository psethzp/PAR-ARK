#!/usr/bin/env python3
"""
Apply PAR-ARK overlay to a cloned mims-harvard/ark repo.
This avoids editing the original ARK files by adding:
- par_main.py
- par_eval.py
- scripts/make_par_tables.py
- prompts/system_prompt_par_ark.md
- src/agents/graph_explorer/par_profile.py
- src/agents/graph_explorer/par_trace.py
- src/agents/graph_explorer/par_graph_explorer.py
"""
from __future__ import annotations
import argparse
from pathlib import Path
import textwrap


def write(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(textwrap.dedent(content).lstrip(), encoding="utf-8")
    print(f"wrote {path}")


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--ark-root", required=True)
    args = ap.parse_args()
    root = Path(args.ark_root).resolve()
    if not (root / "src").exists():
        raise SystemExit(f"Not an ARK root: {root}")

    write(root / "prompts/system_prompt_par_ark.md", r'''
        You are a knowledge-graph retrieval agent. Your task is to find graph nodes that answer the user's question.

        Available node types:
        {node_types}

        Available edge types:
        {edge_types}

        You have four tools:
        1. search_in_graph(query, size): broad lexical search over all node descriptors.
        2. search_in_neighborhood(node_index, query, node_type, edge_type): one-hop expansion around a node.
        3. add_to_answer(node_index, reasoning): add a node to the final ranked answer list.
        4. finish(): stop retrieval.

        PAR-ARK control policy:
        - First parse the PROFILE block if present. It contains target type, facets, soft preferences, and relation hints.
        - Cover all must-cover facets before finishing.
        - Use global search for anchoring entities and text-heavy clues.
        - Use neighborhood search for relation-heavy clues, especially after a promising anchor is found.
        - If a TRACE HINT says a previous action failed, repair instead of repeating it.
        - If neighborhood search returns zero results, relax node_type or edge_type, or re-anchor globally.
        - If global search returns zero results, shorten the query to named entities or key terms.
        - If too many broad candidates appear, tighten by node type, edge type, or missing facet.
        - Avoid repeated identical tool calls.
        - Add likely answer nodes as soon as they are supported; do not wait until the final step.
        - Finish when you have enough supported answer nodes or when budget is nearly exhausted.

        Output must be through tool calls. Do not answer in free text.
    ''')

    write(root / "src/agents/graph_explorer/par_profile.py", r'''
        from __future__ import annotations
        import re
        from dataclasses import dataclass, asdict
        from typing import Iterable

        STOPWORDS = {
            'the','and','or','of','for','to','in','on','with','that','which','what','who','when','where',
            'is','are','was','were','be','been','being','a','an','by','from','as','at','it','this','these',
            'those','find','nodes','answer','question','used','using','have','has','had','into','over','under'
        }

        @dataclass
        class QueryProfile:
            target_entity_type: str | None
            must_cover_facets: list[str]
            relation_hints: list[str]
            soft_preferences: list[str]
            search_bias: str
            raw_keywords: list[str]

            def to_prompt_block(self) -> str:
                return "PROFILE:\n" + str(asdict(self))

        def _keywords(text: str, max_terms: int = 12) -> list[str]:
            words = re.findall(r"[A-Za-z][A-Za-z0-9_\-]{2,}", text.lower())
            out = []
            for w in words:
                if w not in STOPWORDS and w not in out:
                    out.append(w)
                if len(out) >= max_terms:
                    break
            return out

        def build_query_profile(query: str, node_types: Iterable[str], edge_types: Iterable[str], persona: str | None = None) -> QueryProfile:
            q = query.lower()
            node_hits = [nt for nt in node_types if str(nt).lower().replace('_',' ') in q or str(nt).lower() in q]
            edge_hits = [et for et in edge_types if str(et).lower().replace('_',' ') in q or str(et).lower() in q]
            keys = _keywords((persona or '') + ' ' + query)
            target = node_hits[0] if node_hits else None
            # lightweight heuristic: named multiword phrases and rare keywords become facets
            quoted = re.findall(r"['\"]([^'\"]{3,80})['\"]", query)
            capitalized = re.findall(r"(?:[A-Z][A-Za-z0-9_\-]+(?:\s+|$)){1,4}", query)
            facets = []
            for x in quoted + capitalized + keys[:6]:
                x = x.strip().lower()
                if x and x not in facets and x not in STOPWORDS:
                    facets.append(x)
            if edge_hits:
                bias = 'anchor with global search, then traverse relation-filtered neighborhoods'
            elif len(facets) >= 4:
                bias = 'start broad, then tighten by target type and missing facets'
            else:
                bias = 'global search first, add direct matches early'
            soft = []
            for marker in ['recent','latest','open-weight','efficient','personalized','biomedical','academic','product']:
                if marker in q:
                    soft.append(marker)
            return QueryProfile(target, facets[:8], edge_hits[:8], soft, bias, keys)
    ''')

    write(root / "src/agents/graph_explorer/par_trace.py", r'''
        from __future__ import annotations
        import json
        import re
        from dataclasses import dataclass, field, asdict
        from typing import Any

        @dataclass
        class ToolEvent:
            step: int
            tool: str
            args: dict[str, Any]
            result_count: int | None
            zero_result: bool
            repeated: bool
            hint: str

        @dataclass
        class TraceController:
            max_global_searches: int = 6
            max_neighborhood_searches: int = 8
            max_repeated_tool_calls: int = 1
            max_observation_chars: int = 6000
            max_answers: int = 20
            events: list[ToolEvent] = field(default_factory=list)
            call_counts: dict[str, int] = field(default_factory=dict)
            tool_counts: dict[str, int] = field(default_factory=lambda: {'search_in_graph':0, 'search_in_neighborhood':0})

            def _key(self, tool: str, args: dict[str, Any]) -> str:
                return tool + '::' + json.dumps(args, sort_keys=True, default=str)

            def _result_count(self, text: str) -> int | None:
                m = re.search(r"found\s+(\d+)\s+result", text, flags=re.I)
                if m: return int(m.group(1))
                m = re.search(r"Found\s+(\d+)\s+node", text, flags=re.I)
                if m: return int(m.group(1))
                if re.search(r"no nodes found|found no results", text, flags=re.I): return 0
                return None

            def should_stop_before_call(self, selected_answers: int) -> str | None:
                if self.tool_counts.get('search_in_graph',0) >= self.max_global_searches and self.tool_counts.get('search_in_neighborhood',0) >= self.max_neighborhood_searches:
                    return 'Budget exhausted: finish with currently selected answer nodes.'
                if selected_answers >= self.max_answers:
                    return 'Enough answer nodes selected: finish now.'
                return None

            def record(self, step: int, tool: str, args: dict[str, Any], response: str, selected_answers: int) -> tuple[str, str]:
                key = self._key(tool, args)
                self.call_counts[key] = self.call_counts.get(key, 0) + 1
                repeated = self.call_counts[key] > self.max_repeated_tool_calls
                if tool in self.tool_counts:
                    self.tool_counts[tool] = self.tool_counts.get(tool, 0) + 1
                count = self._result_count(response)
                zero = (count == 0) or bool(re.search(r"no nodes found|found no results", response, flags=re.I))
                hint = self._hint(tool, args, count, zero, repeated, selected_answers)
                event = ToolEvent(step, tool, args, count, zero, repeated, hint)
                self.events.append(event)
                if len(response) > self.max_observation_chars:
                    response = response[:self.max_observation_chars] + "\n[Observation truncated by PAR-ARK budget controller.]"
                if hint:
                    response += f"\n\n[PAR-ARK TRACE HINT] {hint}"
                return response, hint

            def _hint(self, tool: str, args: dict[str, Any], count: int | None, zero: bool, repeated: bool, selected_answers: int) -> str:
                hints = []
                if repeated:
                    hints.append('Do not repeat this identical tool call; switch action or change query/filter.')
                if tool == 'search_in_graph':
                    if zero:
                        hints.append('Global search failed: shorten to named entities/key nouns; remove extra modifiers; try synonym or target type.')
                    elif count is not None and count >= 20:
                        hints.append('Broad search is large: choose the best anchor and then use neighborhood search with a type/relation constraint.')
                    else:
                        hints.append('If one anchor matches a required facet, explore its neighborhood before another broad search.')
                elif tool == 'search_in_neighborhood':
                    if zero:
                        hints.append('Neighborhood failed: relax node_type or edge_type; alternatively re-anchor globally using the missing facet.')
                    elif count is not None and count >= 20:
                        hints.append('Neighborhood is broad: tighten by node_type, edge_type, or a more specific facet query.')
                    else:
                        hints.append('If returned nodes answer the question, add them now; otherwise continue one hop from the most relevant node.')
                elif tool == 'add_to_answer':
                    if selected_answers >= 5:
                        hints.append('Several answers selected; finish if remaining facets are covered.')
                return ' '.join(hints)

            def summary(self) -> dict[str, Any]:
                return {
                    'tool_counts': self.tool_counts,
                    'num_events': len(self.events),
                    'zero_result_calls': sum(1 for e in self.events if e.zero_result),
                    'repeated_calls': sum(1 for e in self.events if e.repeated),
                    'events': [asdict(e) for e in self.events],
                }
    ''')

    write(root / "src/agents/graph_explorer/par_graph_explorer.py", r'''
        from __future__ import annotations
        import json
        import time
        from typing import Any
        from src.core.graph import Graph, Node
        from src.core.logger import logger
        from src.agents.graph_explorer.tools.search_in_graph import SearchInGraphTool
        from src.agents.graph_explorer.tools.add_to_answers import AddToAnswer
        from src.agents.graph_explorer.tools.search_in_neighborhood import SearchInNeighborhoodTool
        from src.agents.graph_explorer.tools.finish import FinishTool
        from src.agents.graph_explorer.par_profile import build_query_profile
        from src.agents.graph_explorer.par_trace import TraceController

        class PARGraphExplorerAgent:
            def __init__(self, graph: Graph, model, system_prompt: str, par_mode: str = 'full', persona: str | None = None,
                         max_global_searches: int = 6, max_neighborhood_searches: int = 8,
                         max_observation_chars: int = 6000, max_answers: int = 20):
                self.tools = [SearchInGraphTool(graph), SearchInNeighborhoodTool(graph), AddToAnswer(graph), FinishTool(graph)]
                self.model = model
                self.graph = graph
                self.step = 0
                self.step_times = []
                self.selected_nodes = []
                self.selected_nodes_reasoning = []
                self.par_mode = par_mode
                self.persona = persona
                self.trace = TraceController(max_global_searches=max_global_searches,
                                             max_neighborhood_searches=max_neighborhood_searches,
                                             max_observation_chars=max_observation_chars,
                                             max_answers=max_answers)
                self.message_history = [{"role": "system", "content": system_prompt}]

            def select_tools(self) -> Any:
                model_response = self.model.forward(
                    self.message_history,
                    [tool.schema() for tool in self.tools],
                    tool_choice="required",
                    enable_thinking=False,
                )
                json_response = {"role": "assistant"}
                if hasattr(model_response, "reasoning_content"):
                    json_response["reasoning_content"] = model_response.reasoning_content
                if hasattr(model_response, "content"):
                    json_response["content"] = model_response.content
                if hasattr(model_response, "tool_calls"):
                    json_response["tool_calls"] = [
                        {"id": tc.id, "type": "function", "function": {"name": tc.function.name, "arguments": tc.function.arguments}}
                        for tc in model_response.tool_calls
                    ]
                self.message_history.append(json_response)
                return model_response.tool_calls

            def call_tool(self, selected_tool: Any, tool_call_id: str) -> Any:
                try:
                    args = json.loads(selected_tool.function.arguments) | {"agent": self}
                except Exception:
                    args = {"agent": self}
                tool = next(filter(lambda t: t.name() == selected_tool.function.name, self.tools), None)
                if tool is None:
                    tool_response = f"Tool {selected_tool.function.name} not found."
                else:
                    tool_response = tool(args)
                if self.par_mode in {'trace','full'}:
                    clean_args = {k:v for k,v in args.items() if k != 'agent'}
                    tool_response, _ = self.trace.record(self.step, selected_tool.function.name, clean_args, tool_response, len(self.selected_nodes))
                self.message_history.append({"role": "tool", "content": tool_response, "tool_call_id": tool_call_id})

            def find_nodes(self, query: str, max_steps: int = 30) -> list[Node]:
                if self.par_mode in {'profile','full'}:
                    profile = build_query_profile(query, self.graph.node_types, self.graph.edge_types, persona=self.persona)
                    query = profile.to_prompt_block() + "\n\nTASK:\n" + query
                self.message_history.append({"role": "user", "content": query})
                tool_time = 0.0
                llm_time = 0.0
                start_time = time.time()
                while self.step < max_steps:
                    self.step += 1
                    if self.par_mode in {'trace','full'}:
                        stop_hint = self.trace.should_stop_before_call(len(self.selected_nodes))
                        if stop_hint:
                            self.message_history.append({"role": "user", "content": f"[PAR-ARK BUDGET HINT] {stop_hint}"})
                            break
                    llm_start = time.time()
                    selected_tools = self.select_tools()
                    llm_time += time.time() - llm_start
                    for selected_tool in selected_tools:
                        tool_start = time.time()
                        self.call_tool(selected_tool, selected_tool.id)
                        tool_time += time.time() - tool_start
                        if selected_tool.function.name == "finish":
                            self.step_times.append(time.time() - start_time)
                            return self.selected_nodes
                    self.step_times.append(time.time() - start_time)
                return self.selected_nodes

            def par_summary(self) -> dict[str, Any]:
                return self.trace.summary()
    ''')

    write(root / "par_main.py", r'''
        from __future__ import annotations
        import os, time, json
        from argparse import ArgumentParser
        from pathlib import Path
        from concurrent.futures import ThreadPoolExecutor
        from tqdm import tqdm
        from src.core.logger import logger
        from utils import GraphExplorerConfig, iterate_qas, load_graph, load_model, save_log
        from src.agents.graph_explorer.graph_explorer import GraphExplorerAgent
        from src.agents.graph_explorer.par_graph_explorer import PARGraphExplorerAgent

        def result_dir(args) -> Path:
            model_short = args.model_name.split('/')[-1]
            exp = f"graph_explorer_{model_short}"
            if args.par_mode != 'off': exp += f"_par_{args.par_mode}"
            if args.run_tag: exp += f"_{args.run_tag}"
            d = Path('data/experiments') / args.graph_name / exp / args.split
            d.mkdir(parents=True, exist_ok=True)
            return d

        def write_progress(outdir: Path, event: dict):
            event = dict(event)
            event['updated_at'] = time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime())
            (outdir / 'latest_progress.json').write_text(json.dumps(event, indent=2))
            with open(outdir / 'progress.jsonl', 'a') as f:
                f.write(json.dumps(event) + '\n')

        def completed_log_count(outdir: Path, expected_ids: set[str] | None = None) -> int:
            if expected_ids is not None:
                return sum(1 for qid in expected_ids if (outdir / f'{qid}.json').exists())
            skip = {'latest_progress.json', 'metrics_summary.json', 'config.yaml'}
            return sum(1 for p in outdir.glob('*.json') if p.name not in skip)

        def make_agent(graph, model, args):
            prompt_file = 'prompts/system_prompt.md' if args.par_mode == 'off' else 'prompts/system_prompt_par_ark.md'
            with open(prompt_file, 'r') as f:
                system_prompt = f.read().format(node_types=graph.node_types, edge_types=graph.edge_types)
            if args.par_mode == 'off':
                return GraphExplorerAgent(graph=graph, model=model, system_prompt=system_prompt)
            return PARGraphExplorerAgent(graph=graph, model=model, system_prompt=system_prompt, par_mode=args.par_mode,
                                         persona=args.persona, max_global_searches=args.max_global_searches,
                                         max_neighborhood_searches=args.max_neighborhood_searches,
                                         max_observation_chars=args.max_observation_chars,
                                         max_answers=args.max_answers)

        def run_one(graph, model, args, question: str):
            agent = make_agent(graph, model, args)
            agent.find_nodes(query=f"Find nodes that answer the question: {question}", max_steps=args.max_steps)
            out = {
                'message_history': agent.message_history,
                'agent_answer_indices': [int(node.index) for node in agent.selected_nodes],
                'steps': agent.step,
                'step_times': agent.step_times,
            }
            if hasattr(agent, 'par_summary'):
                out['par_trace_summary'] = agent.par_summary()
            return out

        def run_agents(graph, model, args, question: str):
            # Local vLLM default: sequential agents to prevent OOM from concurrent KV cache.
            if args.parallel_agents:
                workers = args.number_of_agents
                with ThreadPoolExecutor(max_workers=workers) as ex:
                    futs = [ex.submit(run_one, graph, model, args, question) for _ in range(args.number_of_agents)]
                    return [f.result() for f in futs]
            return [run_one(graph, model, args, question) for _ in range(args.number_of_agents)]

        def main():
            p = ArgumentParser(allow_abbrev=False)
            p.add_argument('--graph_name', '--graph-name', '--graph', default='prime')
            p.add_argument('--model_name', '--model-name', default='Qwen/Qwen3-8B')
            p.add_argument('--split', default='test')
            p.add_argument('--number_of_agents', '--number-of-agents', type=int, default=1)
            p.add_argument('--parallel_agents', action='store_true')
            p.add_argument('--finetune_path', '--finetune-path', default=None)
            p.add_argument('--search_mode', '--search-mode', choices=['bm25','embeddings'], default='bm25')
            p.add_argument('--embedding_model', '--embedding-model', default='azure/text-embedding-3-large')
            p.add_argument('--limit', type=int, default=-1)
            p.add_argument('--max_steps', '--max-steps', type=int, default=16)
            p.add_argument('--par_mode', choices=['off','profile','trace','full'], default='full')
            p.add_argument('--run_tag', default='')
            p.add_argument('--persona', default=None)
            p.add_argument('--max_global_searches', type=int, default=6)
            p.add_argument('--max_neighborhood_searches', type=int, default=8)
            p.add_argument('--max_observation_chars', type=int, default=6000)
            p.add_argument('--max_answers', type=int, default=20)
            args = p.parse_args()
            if args.limit == -1: args.limit = None
            cfg = GraphExplorerConfig(graph_name=args.graph_name, model_name=args.model_name,
                                      finetune_path=args.finetune_path, quantized=False,
                                      enable_thinking=False, search_mode=args.search_mode,
                                      embedding_model=args.embedding_model, split=args.split,
                                      max_steps=args.max_steps, limit=args.limit,
                                      number_of_agents=args.number_of_agents)
            graph = load_graph(cfg)
            model = load_model(cfg)
            outdir = result_dir(args)
            logger.info(f'Results saved to {outdir}')
            errors = 0
            qas = iterate_qas(args.graph_name, args.split, limit=args.limit)
            total = len(qas)
            expected_ids = {str(question_id) for question_id, _, _ in qas}
            completed_at_start = completed_log_count(outdir, expected_ids)
            write_progress(outdir, {'status': 'running', 'graph': args.graph_name, 'split': args.split,
                                    'par_mode': args.par_mode, 'run_tag': args.run_tag, 'total': total,
                                    'completed': completed_at_start, 'errors': errors,
                                    'message': 'run started or resumed'})
            pbar = tqdm(qas, total=total, initial=0, desc=f"{args.graph_name}:{args.par_mode}:{args.run_tag}", dynamic_ncols=True)
            for question_id, question, answer_indices in pbar:
                out_file = outdir / f'{question_id}.json'
                if out_file.exists():
                    pbar.set_postfix_str(f"skip existing {question_id}")
                    logger.info(f'Skipping {question_id}; exists')
                    continue
                t0 = time.time()
                try:
                    write_progress(outdir, {'status': 'running', 'graph': args.graph_name, 'split': args.split,
                                            'par_mode': args.par_mode, 'run_tag': args.run_tag, 'total': total,
                                            'completed': completed_log_count(outdir, expected_ids), 'errors': errors,
                                            'current_question_id': str(question_id),
                                            'message': 'processing question'})
                    trajectories = run_agents(graph, model, args, question)
                    save_log({'question': question, 'answer_indices': answer_indices, 'trajectories': trajectories,
                              'time_taken': time.time() - t0, 'par_mode': args.par_mode, 'run_tag': args.run_tag}, outdir, question_id)
                    completed = completed_log_count(outdir, expected_ids)
                    write_progress(outdir, {'status': 'running', 'graph': args.graph_name, 'split': args.split,
                                            'par_mode': args.par_mode, 'run_tag': args.run_tag, 'total': total,
                                            'completed': completed, 'errors': errors,
                                            'current_question_id': str(question_id),
                                            'last_question_seconds': round(time.time() - t0, 3),
                                            'message': 'question completed'})
                    pbar.set_postfix(completed=completed, errors=errors)
                    logger.info(f'Processed {question_id}')
                except Exception as e:
                    logger.error(f'Error processing {question_id}: {e}')
                    errors += 1
                    write_progress(outdir, {'status': 'error_retrying', 'graph': args.graph_name, 'split': args.split,
                                            'par_mode': args.par_mode, 'run_tag': args.run_tag, 'total': total,
                                            'completed': completed_log_count(outdir, expected_ids), 'errors': errors,
                                            'current_question_id': str(question_id), 'error': repr(e),
                                            'message': 'question failed; sleeping before next item'})
                    time.sleep(3)
                    if errors > 50:
                        raise
            write_progress(outdir, {'status': 'completed', 'graph': args.graph_name, 'split': args.split,
                                    'par_mode': args.par_mode, 'run_tag': args.run_tag, 'total': total,
                                    'completed': completed_log_count(outdir, expected_ids), 'errors': errors,
                                    'message': 'run complete'})
            logger.info('PAR-ARK run complete')
        if __name__ == '__main__': main()
    ''')

    write(root / "par_eval.py", r'''
        from __future__ import annotations
        import json, os
        import pandas as pd
        from argparse import ArgumentParser
        from pathlib import Path
        from collections import Counter

        def safe_open_json(path: Path):
            try:
                return json.loads(path.read_text())
            except Exception as e:
                print(f'BAD_JSON {path}: {e}')
                return None

        def logs_dir(args) -> Path:
            if args.logs_dir:
                return Path(args.logs_dir)
            model_short = args.model_name.split('/')[-1]
            exp = f'graph_explorer_{model_short}'
            if args.par_mode != 'off': exp += f'_par_{args.par_mode}'
            if args.run_tag: exp += f'_{args.run_tag}'
            return Path('data/experiments') / args.graph_name / exp / args.split

        def load_metrics_df(logs: Path, max_agents: int | None):
            rows = []
            for jf in sorted(logs.glob('*.json')):
                d = safe_open_json(jf)
                if d is None: continue
                trajs = d.get('trajectories', [])
                if max_agents is not None: trajs = trajs[:max_agents]
                flat = []
                for tr in trajs:
                    flat.extend(tr.get('agent_answer_indices', []))
                counts = Counter(flat)
                first_seen = {}
                for i, idx in enumerate(flat): first_seen.setdefault(idx, i)
                combined = sorted(counts.keys(), key=lambda x: (-counts[x], first_seen[x]))
                gold = set(d.get('answer_indices', []))
                rr = 0.0
                for rank, idx in enumerate(combined, 1):
                    if idx in gold:
                        rr = 1.0 / rank; break
                trace_summaries = [tr.get('par_trace_summary', {}) for tr in trajs]
                rows.append({
                    'question_id': jf.stem,
                    'hit@1': bool(combined and combined[0] in gold),
                    'hit@5': bool(gold.intersection(combined[:5])),
                    'recall@10': len(gold.intersection(combined[:10])) / max(1, len(gold)),
                    'recall@20': len(gold.intersection(combined[:20])) / max(1, len(gold)),
                    'recall@all': len(gold.intersection(combined)) / max(1, len(gold)),
                    'MRR': rr,
                    'time_taken': d.get('time_taken'),
                    'steps_mean': sum(tr.get('steps', 0) for tr in trajs) / max(1, len(trajs)),
                    'zero_result_calls': sum(ts.get('zero_result_calls', 0) for ts in trace_summaries),
                    'repeated_calls': sum(ts.get('repeated_calls', 0) for ts in trace_summaries),
                    'global_searches': sum(ts.get('tool_counts', {}).get('search_in_graph', 0) for ts in trace_summaries),
                    'neighborhood_searches': sum(ts.get('tool_counts', {}).get('search_in_neighborhood', 0) for ts in trace_summaries),
                })
            return pd.DataFrame(rows)

        def main():
            p = ArgumentParser()
            p.add_argument('--graph_name', default='prime')
            p.add_argument('--model_name', default='Qwen/Qwen3-8B')
            p.add_argument('--split', default='test')
            p.add_argument('--run_tag', default='')
            p.add_argument('--par_mode', choices=['off','profile','trace','full'], default='full')
            p.add_argument('--max_agents', type=int, default=1)
            p.add_argument('--logs_dir', default=None)
            args = p.parse_args()
            ld = logs_dir(args)
            df = load_metrics_df(ld, args.max_agents)
            if len(df) == 0:
                print(f'No rows found in {ld}')
                return
            metrics = {
                'logs_dir': str(ld), 'n': int(len(df)),
                'Hit@1': round(float(df['hit@1'].mean()), 4),
                'Hit@5': round(float(df['hit@5'].mean()), 4),
                'Recall@10': round(float(df['recall@10'].mean()), 4),
                'Recall@20': round(float(df['recall@20'].mean()), 4),
                'Recall@all': round(float(df['recall@all'].mean()), 4),
                'MRR': round(float(df['MRR'].mean()), 4),
                'TimeTakenMean': round(float(df['time_taken'].mean()), 3) if df['time_taken'].notna().any() else None,
                'StepsMean': round(float(df['steps_mean'].mean()), 3),
                'GlobalSearchesMean': round(float(df['global_searches'].mean()), 3),
                'NeighborhoodSearchesMean': round(float(df['neighborhood_searches'].mean()), 3),
                'ZeroResultCallsMean': round(float(df['zero_result_calls'].mean()), 3),
                'RepeatedCallsMean': round(float(df['repeated_calls'].mean()), 3),
            }
            print(json.dumps(metrics, indent=2))
            out = ld / 'metrics_summary.json'
            out.write_text(json.dumps(metrics, indent=2))
            df.to_csv(ld / 'per_question_metrics.csv', index=False)
        if __name__ == '__main__': main()
    ''')

    write(root / "scripts/make_par_tables.py", r'''
        from __future__ import annotations
        import argparse, json
        from pathlib import Path

        def main():
            ap = argparse.ArgumentParser()
            ap.add_argument('--root', default='data/experiments')
            ap.add_argument('--out', default='paper_tables/par_ark_tables.md')
            args = ap.parse_args()
            rows = []
            for p in Path(args.root).glob('*/*/*/metrics_summary.json'):
                try: m = json.loads(p.read_text())
                except Exception: continue
                parts = p.parts
                # data/experiments/{graph}/{experiment}/{split}/metrics_summary.json
                graph, exp, split = parts[-4], parts[-3], parts[-2]
                rows.append((graph, exp, split, m))
            lines = ['# PAR-ARK Metrics Tables', '', '| graph | experiment | split | n | Hit@1 | Hit@5 | R@20 | MRR | steps | global | neigh | zero | repeat |', '|---|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|']
            for graph, exp, split, m in sorted(rows):
                lines.append(f"| {graph} | {exp} | {split} | {m.get('n')} | {m.get('Hit@1')} | {m.get('Hit@5')} | {m.get('Recall@20')} | {m.get('MRR')} | {m.get('StepsMean')} | {m.get('GlobalSearchesMean')} | {m.get('NeighborhoodSearchesMean')} | {m.get('ZeroResultCallsMean')} | {m.get('RepeatedCallsMean')} |")
            Path(args.out).parent.mkdir(parents=True, exist_ok=True)
            Path(args.out).write_text('\n'.join(lines))
            print(f'wrote {args.out}')
        if __name__ == '__main__': main()
    ''')


    write(root / "scripts/offline_rerank_qwen3.py", r"""
        from __future__ import annotations
        import argparse, json
        from pathlib import Path
        from collections import Counter
        from sentence_transformers import CrossEncoder
        from utils import GraphExplorerConfig, load_graph, save_log

        def combine(trajs, max_candidates=50):
            flat=[]
            for tr in trajs:
                flat.extend(tr.get('agent_answer_indices', []))
            counts=Counter(flat)
            first={}
            for i,x in enumerate(flat): first.setdefault(x,i)
            return sorted(counts.keys(), key=lambda x:(-counts[x], first[x]))[:max_candidates]

        def node_doc(graph, idx):
            node=graph.get_node_by_index(int(idx))
            parts=[f"Name: {getattr(node,'name','')}", f"Type: {getattr(node,'type','')}"]
            summ=getattr(node,'summary',None)
            if summ: parts.append(f"Text: {summ}")
            return "\n".join(parts)

        def main():
            ap=argparse.ArgumentParser()
            ap.add_argument('--graph_name', required=True)
            ap.add_argument('--in_logs_dir', required=True)
            ap.add_argument('--out_logs_dir', required=True)
            ap.add_argument('--reranker_model', default='Qwen/Qwen3-Reranker-8B')
            ap.add_argument('--max_candidates', type=int, default=50)
            ap.add_argument('--batch_size', type=int, default=4)
            args=ap.parse_args()
            cfg=GraphExplorerConfig(graph_name=args.graph_name, model_name='Qwen/Qwen3-8B')
            graph=load_graph(cfg)
            model=CrossEncoder(args.reranker_model, trust_remote_code=True)
            out=Path(args.out_logs_dir); out.mkdir(parents=True, exist_ok=True)
            for jf in sorted(Path(args.in_logs_dir).glob('*.json')):
                d=json.loads(jf.read_text())
                q=d.get('question','')
                cands=combine(d.get('trajectories',[]), args.max_candidates)
                docs=[node_doc(graph, idx) for idx in cands]
                if docs:
                    scores=model.predict([(q, doc) for doc in docs], batch_size=args.batch_size)
                    pairs=sorted(zip(cands, scores), key=lambda x: float(x[1]), reverse=True)
                    reranked=[int(x[0]) for x in pairs]
                else:
                    reranked=[]
                new=dict(d)
                new['trajectories']=[{'agent_answer_indices': reranked, 'steps': 0, 'step_times': [], 'reranker': args.reranker_model}]
                save_log(new, out, jf.stem)
            print(f'wrote reranked logs to {out}')
        if __name__=='__main__': main()
    """)

if __name__ == "__main__":
    main()
