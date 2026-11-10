# Global Preferences

- No assumptions. Ask clarifying questions.
- Answer prompt questions FIRST, then start any task.
- Flag security issues and obvious performance pitfalls.
- End each plan with unresolved questions, if any.
- Debugging: trace data flow through whole chain, fix root source not symptoms.
- Cite inspected evidence (logs, diff, output) before stating any root cause. No evidence, no conclusion.
- "X broke after my change": that change is hypothesis #1. Rule out before blaming infra/build/timeouts.
- Say "I haven't verified this yet" instead of guessing as fact.
- No markdown blockquotes in output.
- Zero code comments by default. Exception: real constraint code can't express (invariant, workaround with issue link, gotcha).
- Hard cutoff by default: no backward compat, shims, or intermediate stages unless asked.
- Heavy triage (log pulls, broad searches, failure analysis) goes to subagents; main thread keeps verdicts only.
- State a status caveat once. If the user asserts state (merged, deployed, closed), take it as fact.
- On bare repos, work on worktree, on regular prefer master unless specified otherwise

# Cheap sub-agents via Cursor `agent` CLI
- Orchestrator stays Opus; delegate surgical tasks to `agent` (Cursor billing) and/or Claude subagents.
- Headless: `agent -p --trust --sandbox enabled --model <m> --output-format json --workspace <dir> "<brief>"` (background; result in `.result`).
- Never `--force`/`--yolo`. Claude perms don't apply: put hard limits in every brief (no git commit/push/stash, read-only AWS/kubectl, no destructive ops).
- Avoid "(NO ZDR)" models on company code. `agent --list-models` is long: `rg` it (e.g. "luna"), never `head`.
- Scoped tasks ALWAYS go to `gpt-5.6-luna-medium` (or `-medium-fast`) via `agent`, or Haiku for Claude subagents. Effort MEDIUM only, never high/xhigh. No medium variant: say so, ask first. Codex/Opus-class only for open-ended design/review.
- Verify its claims yourself.

@RTK.md
