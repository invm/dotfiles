#!/usr/bin/env python3
"""Weekly digest of Claude Code sessions across all projects.

usage: retro.py [--days N] [--check]
Writes ~/.claude/retro/<date>.md and prints its path.
"""
import json
import re
import subprocess
import sys
import time
from collections import Counter, defaultdict
from datetime import date
from pathlib import Path

PROJECTS = Path.home() / ".claude" / "projects"
OUT = Path.home() / ".claude" / "retro"
STATS = Path(__file__).resolve().parent.parent / "trailblazer" / "stats.py"
CORRECTION = re.compile(
    r"\b(no|not|don'?t|didn'?t|doesn'?t|wrong|why (did|are|do|is)|i (said|asked|told|meant)|again|stop|instead|revert|undo"
    r"|shouldn'?t|should (not|have)|never|always|from now on|actually|disagree|you (missed|forgot|skipped|ignored))\b",
    re.I,
)
INTERRUPT = "[Request interrupted by user"
NOT_TYPED = ("<", "This session is being continued", "Caveat:", "Base directory for this skill", INTERRUPT)


def typed_text(entry):
    if entry.get("type") != "user" or entry.get("isMeta") or entry.get("isSidechain"):
        return ""
    content = entry.get("message", {}).get("content")
    if isinstance(content, list):
        if any(part.get("type") == "tool_result" for part in content if isinstance(part, dict)):
            return ""
        content = " ".join(part.get("text", "") for part in content if isinstance(part, dict) and part.get("type") == "text")
    text = (content or "").strip()
    return "" if text.startswith(NOT_TYPED) else text


def first_line(content):
    if isinstance(content, list):
        content = " ".join(part.get("text", "") for part in content if isinstance(part, dict))
    lines = [line for line in (content or "").strip().split("\n") if line.strip() and not line.startswith("Exit code")]
    line = lines[0].strip() if lines else "no output"
    return re.sub(r"\d+", "N", re.sub(r"/\S+", "<path>", line))[:110]


def read(files, since):
    projects = defaultdict(lambda: {"sessions": set(), "messages": 0, "corrections": [], "interrupts": 0, "errors": Counter()})
    for file in files:
        name, tools = file.parent.name, {}
        for raw in file.open(errors="replace"):
            try:
                entry = json.loads(raw)
            except ValueError:
                continue
            stamp = entry.get("timestamp", "")
            if not isinstance(entry.get("message"), dict) or stamp[:10] < since:
                continue
            name = entry.get("cwd") or name
            project = projects[name]
            content = entry["message"].get("content")
            for part in content if isinstance(content, list) else []:
                if not isinstance(part, dict):
                    continue
                if part.get("type") == "tool_use":
                    tools[part.get("id")] = part.get("name", "?")
                elif part.get("type") == "tool_result" and part.get("is_error") and not entry.get("isSidechain"):
                    project["errors"][(tools.get(part.get("tool_use_id"), "?"), first_line(part.get("content")))] += 1
            if INTERRUPT in json.dumps(content)[:200] and entry.get("type") == "user":
                project["interrupts"] += 1
            text = typed_text(entry)
            if text:
                project["sessions"].add(file.stem)
                project["messages"] += 1
                if CORRECTION.search(text):
                    project["corrections"].append((stamp[:16], file.stem[:8], " ".join(text.split())[:400]))
    return projects


def trailblazer(files):
    if not STATS.exists() or not files:
        return []
    out = subprocess.run([sys.executable, str(STATS), *map(str, files)], capture_output=True, text=True).stdout
    return [line for line in out.splitlines() if re.match(r"\d+ runs|agents running|agent time|fix rounds", line)]


def check():
    user = lambda content, **extra: {"type": "user", "message": {"content": content}, **extra}
    assert typed_text(user("no, use the other one")) == "no, use the other one"
    assert typed_text(user("<command-name>/retro</command-name>")) == ""
    assert typed_text(user([{"type": "tool_result", "content": "x"}])) == ""
    assert typed_text(user("hi", isSidechain=True)) == ""
    assert CORRECTION.search("Why did you skip it") and not CORRECTION.search("yes commit and push")
    assert first_line("Exit code 1\n/tmp/a.py:12 failed") == "<path> failed"
    print("ok")


def main():
    if "--check" in sys.argv:
        return check()
    days = int(sys.argv[sys.argv.index("--days") + 1]) if "--days" in sys.argv else 7
    cutoff = time.time() - days * 86400
    since = time.strftime("%Y-%m-%d", time.gmtime(cutoff))
    files = [file for file in PROJECTS.glob("*/*.jsonl") if file.stat().st_mtime >= cutoff]
    projects = read(files, since)
    lines = [f"# Retro digest, {since} to {date.today()}", ""]
    for name, project in sorted(projects.items(), key=lambda item: -len(item[1]["corrections"])):
        repeated = [(key, count) for key, count in project["errors"].most_common(8) if count >= 3]
        if not project["corrections"] and not repeated:
            continue
        lines += [f"## {name}", "", f"{len(project['sessions'])} sessions, {project['messages']} typed messages, "
                  f"{len(project['corrections'])} possible corrections, {project['interrupts']} interrupts", ""]
        lines += trailblazer([file for file in files if file.stem in project["sessions"]])
        if repeated:
            lines += ["", "Repeated tool errors:", *[f"- {count}x {tool}: {line}" for (tool, line), count in repeated]]
        if project["corrections"]:
            lines += ["", "Possible corrections (time, session, text):", *[f"- {stamp} {session} {text}" for stamp, session, text in project["corrections"]]]
        lines.append("")
    OUT.mkdir(exist_ok=True)
    path = OUT / f"{date.today()}.md"
    path.write_text("\n".join(lines))
    print(path)


main()
