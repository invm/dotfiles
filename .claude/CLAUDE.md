# Global Preferences

## Communication

- Answer prompt questions FIRST, then start any task.
- Don't assume, ask.
- End each plan with unresolved questions, if any.
- No markdown blockquotes in output.

## Debugging & Evidence

- Debugging: trace data flow through whole chain, fix root source not symptoms.
- Cite inspected evidence (logs, diff, output) before stating any root cause. No evidence, no conclusion.
- "X broke after my change": that change is hypothesis #1. Rule out before blaming infra/build/timeouts.
- Say "I haven't verified this yet" instead of guessing as fact.
- Verify through the project's supported harness. If it's blocked, stop and report. Never call a substitute equivalent.

## Code & Changes

- Zero code comments by default. Exception: real constraint code can't express (invariant, workaround with issue link, gotcha).
- No secret-shaped test data.
- Hard cutoff by default: no backward compat, shims, or intermediate stages unless asked.
- Hard cutoff never covers removing user-visible behavior or deleting tests. Each such removal needs my explicit approval, asked before coding, and the PR lists it under "## Removed behavior" with what replaces it.

## Safety & Scope

- Flag security issues and obvious performance pitfalls.
- Never create AWS resources without asking.
- Touch only the environments the user is working on. Plan or check another environment only when the user asks.

## Delegation

- Heavy triage (log pulls, broad searches, failure analysis) goes to subagents; main thread keeps verdicts only.
- Subagent briefs name the project's supported harness and offer no fallback.

## Git

- On bare repos, work on worktree, on regular prefer master unless specified otherwise.

@RTK.md
