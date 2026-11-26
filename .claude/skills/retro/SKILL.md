---
name: retro
description: Weekly retro over the Claude Code sessions of every project. Extracts the user's corrections, repeated tool errors, interrupts and trailblazer numbers, then prints ranked proposals to add, sharpen or delete rules, skills, hooks and agent files. Use when the user says "retro" or asks what to improve in how Claude works for them.
---

# Retro

A lesson is a mistake that happened twice, or a standing instruction the user gave once ("always", "never", "from now on"). The retro turns lessons into changes the next session meets without being told, and removes rules that no longer earn their place.

The digest and the decisions file quote private sessions. They stay in `~/.claude/retro/`. A proposal's text for a tracked file is written fresh, without quotes, project names or people.

## 1. Extract

Run `python3 retro.py` from this skill's directory (`--days N` for another window, default 7). It prints the path of the digest. Read the digest and `~/.claude/retro/decisions.md`.

Each project section holds session counts, the trailblazer numbers of the window, tool errors seen three or more times, and the user's messages that may be corrections, each with time and session id. When a message alone does not show what the assistant did wrong, read the turns before it in `~/.claude/projects/*/<session id>*.jsonl`.

## 2. Find the lessons

- Group the corrections and errors by cause, across projects. Drop one-off task steering.
- For each lesson, find where it is already written: the global `CLAUDE.md`, the repo's `CLAUDE.md`, a skill, an agent file, a hook.
- Written and still broken: propose a mechanical check (hook, lint rule, script) or sharper wording in that same place. Never a second copy.
- Not written: propose it in the narrowest place that every affected session reads. A lesson seen in two or more projects goes global; otherwise it goes in the repo.
- For each rule that the digest's sessions exercised, in the files you opened: propose deleting the ones that state what the model does anyway, and the ones whose reason is gone.
- Compare the trailblazer `fix rounds per build round` with the last digest that has one. A rise is a lesson; find its cause in the fix-round briefs.

Done when every correction in the digest is in a lesson or dropped with a reason you can state.

## 3. Propose

Print one table, at most ten rows, ranked by occurrences:

| # | Lesson | Evidence | Change | Kind |
|---|---|---|---|---|
| 1 | what went wrong, one line | count, projects, one short quote | file, then add, edit or delete, with the exact text | mechanical or prose |

Leave out a lesson that `decisions.md` records as rejected, unless its count has doubled since. Under the table, list in one line each what you dropped and why.

Then ask which numbers to apply, and wait.

## 4. Apply

Apply each approved change in the file the row names, under that repo's own rules for branches, issues and pull requests. Append every row to `~/.claude/retro/decisions.md`: date, lesson, change, `accepted` or `rejected`.
