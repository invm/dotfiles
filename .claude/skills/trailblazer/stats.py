#!/usr/bin/env python3
"""Time split of past trailblazer runs, read from Claude Code session files.

usage: stats.py [session.jsonl | project-directory ...]
With no argument it reads the sessions of the current directory's project.
"""
import json
import os
import re
import statistics
import sys
from datetime import datetime
from pathlib import Path

INVOKED = re.compile(r'<command-name>/trailblazer|"skill": ?"trailblazer"')
CI_WATCH = re.compile(r"gh (pr checks|run watch)")
KINDS = (
    ("verify", re.compile(r"qa|verif|real run|smoke|e2e|screenshot|ui.review")),
    ("fix", re.compile(r"\bfix|rework|address|follow.?up")),
    ("lookup", re.compile(r"look|find|where|read|check|investigat|explore|triage|diagnos|review|ruling|audit|pathfinder")),
    ("build", re.compile(r"build|implement|contract|#\d+|add|remove|refactor|migrat")),
)
KIND_NAMES = ("build", "fix", "verify", "lookup", "other")
COLUMNS = "session   start        span  agents-on  your-answer   rest | rounds  median    p90  at-once | merges  h/merge  rounds/merge  fix/build  questions  ci-watch"


def parse_time(value):
    return datetime.fromisoformat(value.replace("Z", "+00:00"))


def session_files(args):
    if not args:
        args = [Path.home() / ".claude" / "projects" / re.sub(r"[^A-Za-z0-9]", "-", os.getcwd())]
    for arg in map(Path, args):
        yield from sorted(arg.glob("*.jsonl")) if arg.is_dir() else [arg]


def text_of(content):
    if isinstance(content, str):
        return content
    if isinstance(content, list):
        return " ".join(part.get("text", "") for part in content if isinstance(part, dict) and part.get("type") == "text")
    return ""


def parts(content, kind):
    return [part for part in content if isinstance(part, dict) and part.get("type") == kind] if isinstance(content, list) else []


def kind_of(description):
    lowered = description.lower()
    first = lowered.split(" ", 1)[0].rstrip(":")
    if first in KIND_NAMES:
        return first
    return next((name for name, pattern in KINDS if pattern.search(lowered)), "other")


def union_seconds(intervals):
    total, current = 0.0, None
    for start, end in sorted(intervals):
        if current and start <= current[1]:
            current = (current[0], max(current[1], end))
            continue
        if current:
            total += (current[1] - current[0]).total_seconds()
        current = (start, end)
    return total + ((current[1] - current[0]).total_seconds() if current else 0.0)


def measure(path):
    raw = path.read_text(errors="replace")
    if not INVOKED.search(raw):
        return None
    events = []
    for line in raw.splitlines():
        try:
            event = json.loads(line)
        except ValueError:
            continue
        if isinstance(event, dict) and event.get("timestamp"):
            events.append(event)
    events.sort(key=lambda event: event["timestamp"])

    running, rounds, questions_open, ci_open, kinds = {}, [], {}, {}, {}
    count = dict.fromkeys(KIND_NAMES, 0)
    seconds = dict.fromkeys(KIND_NAMES, 0.0)

    def finish(use_id, now):
        start = running.pop(use_id)
        rounds.append((start, now))
        seconds[kinds[use_id]] += (now - start).total_seconds()

    started = first = last = previous = None
    waited_on_user = ci_watch = 0.0
    merges = questions = dispatched = 0

    for event in events:
        now, kind = parse_time(event["timestamp"]), event.get("type")
        message = event.get("message")
        content = message.get("content") if isinstance(message, dict) else None
        if not started:
            if kind not in ("user", "assistant") or not INVOKED.search(json.dumps(content)):
                continue
            started, first, previous = True, now, now
        last = now

        if kind == "queue-operation" and "<task-notification>" in str(event.get("content", "")):
            match = re.search(r"<tool-use-id>([^<]+)", event["content"])
            if match and match.group(1) in running:
                finish(match.group(1), now)
        elif kind == "assistant":
            for use in parts(content, "tool_use"):
                name, call = use.get("name"), use.get("input", {})
                if name in ("Agent", "Task"):
                    running[use["id"]] = now
                    kinds[use["id"]] = kind_of(f"{call.get('description', '')} {call.get('subagent_type', '')}")
                    count[kinds[use["id"]]] += 1
                    dispatched += 1
                elif name == "AskUserQuestion":
                    questions += 1
                    questions_open[use["id"]] = now
                elif name == "Bash":
                    command = call.get("command", "")
                    merges += "gh pr merge" in command
                    if CI_WATCH.search(command):
                        ci_open[use["id"]] = now
        elif kind == "user":
            results = parts(content, "tool_result")
            for result in results:
                use_id = result.get("tool_use_id")
                if use_id in questions_open:
                    waited_on_user += (now - questions_open.pop(use_id)).total_seconds()
                if use_id in ci_open:
                    ci_watch += (now - ci_open.pop(use_id)).total_seconds()
                if use_id in running and (now - running[use_id]).total_seconds() > 90:
                    finish(use_id, now)
            typed = text_of(content).strip()
            if typed and not results and not event.get("isMeta") and "<task-notification>" not in typed:
                gap = (now - previous).total_seconds()
                if gap > 120 and not running:
                    waited_on_user += gap
        if kind in ("user", "assistant"):
            previous = now

    if not started:
        return None
    span = (last - first).total_seconds()
    agents_on = union_seconds(rounds)
    minutes = sorted((end - start).total_seconds() / 60 for start, end in rounds)
    return {
        "session": path.stem[:8],
        "start": first.strftime("%m-%d %H:%M"),
        "span": span,
        "agents_on": agents_on,
        "user": waited_on_user,
        "rest": max(span - agents_on - waited_on_user, 0.0),
        "rounds": dispatched,
        "median": statistics.median(minutes) if minutes else 0.0,
        "p90": minutes[max(int(len(minutes) * 0.9) - 1, 0)] if minutes else 0.0,
        "at_once": sum(minutes) * 60 / agents_on if agents_on else 0.0,
        "merges": merges,
        "questions": questions,
        "ci": ci_watch,
        "count": count,
        "seconds": seconds,
    }


def row(run):
    hours = lambda seconds: f"{seconds / 3600:6.1f}h"
    merges = max(run["merges"], 1)
    return (
        f"{run['session']}  {run['start']} {hours(run['span'])}   {hours(run['agents_on'])}     {hours(run['user'])} {hours(run['rest'])} |"
        f" {run['rounds']:6d} {run['median']:6.0f}m {run['p90']:5.0f}m {run['at_once']:8.1f} |"
        f" {run['merges']:6d} {run['span'] / 3600 / merges:8.1f} {run['rounds'] / merges:13.1f} {run['count']['fix'] / max(run['count']['build'], 1):10.2f} {run['questions']:10d}  {hours(run['ci'])}"
    )


def main():
    runs = [run for run in map(measure, session_files(sys.argv[1:])) if run]
    if not runs:
        sys.exit("no trailblazer session found")
    runs.sort(key=lambda run: run["start"])
    print(COLUMNS)
    for run in runs:
        print(row(run))
    total = {key: sum(run[key] for run in runs) for key in ("span", "agents_on", "user", "rest", "rounds", "merges", "questions", "ci")}
    share = lambda key: f"{100 * total[key] / total['span']:.0f}%"
    count = {name: sum(run["count"][name] for run in runs) for name in KIND_NAMES}
    seconds = {name: sum(run["seconds"][name] for run in runs) for name in KIND_NAMES}
    agent_seconds = sum(seconds.values()) or 1.0
    print(
        f"\n{len(runs)} runs, {total['span'] / 3600:.0f}h, {total['merges']} merges, {total['span'] / 3600 / max(total['merges'], 1):.1f}h per merge, "
        f"{total['rounds'] / max(total['merges'], 1):.1f} rounds per merge\n"
        f"agents running {share('agents_on')}, waiting on your answer {share('user')}, rest {share('rest')}, ci watch {share('ci')}\n"
        "agent time by round: " + ", ".join(f"{name} {100 * seconds[name] / agent_seconds:.0f}% ({count[name]})" for name in KIND_NAMES) + "\n"
        f"fix rounds per build round: {count['fix'] / max(count['build'], 1):.2f}\n"
        "round kind = first word of the agent description, else keywords in it\n"
        "rest = dispatcher work plus idle time the session file does not explain; the timing log on the map issue splits it"
    )


if __name__ == "__main__":
    main()
