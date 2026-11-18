---
name: trailblazer
description: Dispatcher for a wayfinder map, a GitHub issue that lists tickets and their order. Runs the whole map with subagents - build, review, deploy to allowed environments, verify on the real environment, merge, clean up - and ends with a report. Use when the user gives a wayfinder map issue and asks to run, dispatch or finish it, or says "trailblazer".
---

# Trailblazer

You are the dispatcher for a wayfinder map: a GitHub issue that lists tickets
and their order. Argument: the map issue URL. Your job is control flow and
review. Subagents do the work. You finish the whole map in this session unless
a decision only the user can make blocks it.

The user's trust rests on **receipts**. A receipt is the command and its
output, a screenshot path, or a measured number that proves one claim. Every
"done", "works", "passes", "no X" and "fixed" you or an agent states carries a
receipt. A claim without one is a guess: verify it or label it "not verified".

## Before any work

1. Read the map, every ticket on it, and the repo's CLAUDE.md. Build the
   dependency order. Before you mark two tickets parallel, grep for code both
   will touch (shared components, helpers, formatters). Overlap makes them
   sequential.
2. Ask the user everything that could block you later, in one batch. Every
   item gets asked:
   - merge flow (default: push, PR with `Closes #n`, wait for CI, squash-merge);
     the answer is standing approval for this map, including tickets added to
     it later
   - which environments you may deploy to, and whether they are disposable
   - tickets to skip
   - cost and real-run budget
3. After that, do not stop to ask. For any decision the tickets leave open, take
   the simplest default, record it under "Decisions so far" on the map issue and
   in the PR body, and move on.
4. The map issue is the session's memory. After every round, update it: ticket
   status, decisions, the leftovers list. A fresh session must be able to resume
   from the issue alone, because your context will run out and get summarised.

## Models and load

- Build rounds and verification rounds: Opus subagents.
- Lookups (where is X, what calls Y, read this log): Haiku subagents.
- You review and decide. You do not build.
- At most two heavy agents at once (builds, test suites, dev servers). Full
  test suites and end-to-end runs go one at a time across the whole map. Check
  `uptime` before you dispatch; above the core count, wait.

## Loop per ticket

1. Worktree and branch for the ticket. One agent per worktree, never two.
2. **Build round.** The agent implements, tests, commits locally, and stops
   before any push or infrastructure change. Its report lists what it did not
   verify.
3. **Your review.** Read the diff for scope creep, comments the repo forbids,
   security rules, dead code, and unquestioned defaults (a page size of 10, a
   cap of 100, a hidden field): each one is either justified in the PR body or
   changed. Then **re-run one claim yourself**: the test command, the curl, the
   plan. An agent's report is a claim; your re-run is the receipt.
4. **Infrastructure.** You run plan, read it, and apply, only to environments
   the user allowed. Re-plan afterwards to confirm no drift. Then trace the
   **deploy path**: every workflow, role and policy that will create, update or
   read the new resource. Confirm from plan output or IAM policy that each one
   has access. Write down what the other environments will need.
5. **Verification round**, always a separate agent from the builder, against
   the real environment. Aim it at the build agent's "not verified" list. Give
   it a budget (runs, hosts, money). Passing unit tests have missed a stale
   image, an 80-second delay, an open port and a missing IAM statement; only a
   real run found them.
6. Fix round if needed. Before merge: main branch merged in, PR body matches
   the final diff, UI PRs carry their screenshots, every leftover from this
   ticket has a fate. Then push, PR, CI green, merge, confirm the issue closed,
   delete the worktree and the local and remote branches.

## Before every round

Run the **preflight**: the harness the round needs answers before you spend an
agent on it. Dev server or staging returns 200, the database is migrated and
seeded, the browser tool connects, setup steps the repo needs in a fresh
worktree (port offset, building shared packages) are done or in the brief.
A failed preflight is a blocker: fix it or tell the user. Do not send an agent
into a broken harness, and do not send a second one into the same failure.

## Verification

Size it to the ticket. The cheapest check that would fail if the change were
wrong is the right one.

| Ticket | Check | Receipt |
|---|---|---|
| Removal, refactor, docs, config | CI script | exit code |
| Server, API, action | Unit tests, plus one real call against the running app, signed in with the repo's headless sign-in recipe | response body, inspected for infrastructure identifiers |
| CLI | Unit tests, plus the built CLI run against a real environment, exercising every changed flag and one wrong input | command line and output |
| UI | The changed screens measured in a headless browser, see below | screenshot grid and measurements |
| Infrastructure, runtime | Real run on the allowed environment, plus the deploy path | run output, plan output |

After any deploy, call the public routes the deploy exposes and read what they
return to an anonymous caller.

- **Inner loop is fast and deterministic.** While building, an agent runs only
  the tests of the files it touched, and they must finish in seconds. No sleeps,
  no retries to get green, no dependence on test order or on the network.
- **End-to-end is on demand.** Most tickets need none. When a ticket changes a
  user journey, run only the specs for that area, once, at the end of the
  ticket. The full suite runs at most once per map, before the last merge, and
  only if the map changed shared code such as auth, routing or layout.
- **Extend an existing test before writing a new one.** Find the test file or
  spec that already covers the area and add the case or assertion there.
- **Every failure is a bug until proven otherwise.** Blaming load, seed data,
  flakiness or "pre-existing" needs a receipt: the same failure on the main
  branch, or the line in the log that shows the cause. Without one, the failure
  is fixed in the ticket. Never rerun a failing check, locally or in CI, until
  you know why it failed.

### UI tickets

- Before designing a new screen, look at how one established product solves
  the same screen (docs, screenshots, demo). Note what you take from it in the
  PR body.
- Design with the `hallmark` skill. Name it in the build brief; an agent does
  not reach for a skill it was not told about. The goal is a frictionless
  product: the next action is obvious, nothing needs explaining, empty and
  error states say what to do.
- List every **surface** the change reaches before verifying: routes, dialogs,
  emails, and pages rendered by frameworks or libraries outside the route tree
  (sign-in, error pages). A style or token change reaches all of them.
- Verify with the repo's UI review skill, named in the brief, in a headless
  browser at 390, 768 and 1366 px, light and dark. Measure, do not eyeball:
  sideways overflow, alignment of the changed elements with their neighbours
  (bounding boxes), padding and margins (computed style) against the
  neighbouring page.
- Walk a full journey from sign-in only when the ticket adds or changes a
  journey. Only then cover it end to end, by extending the spec that already
  walks that area if one exists.
- Screenshots go on the PR before merge. Never commit screenshots.

## Leftovers

A **leftover** is anything found during a ticket that the ticket did not ask
for: a bug, a gap, a rough edge. Decide its fate the moment it is found:

- **Small** (under about 50 lines, in code the ticket already touches or its
  direct neighbours, no decision only the user can make): open a ticket for it
  now, fix it in the same PR, and add `Closes #<new>` to the PR body and the
  commit.
- **Blocks the map**: open a ticket and fix it before the blocked ticket.
- **Everything else**: open a ticket and put it on the leftovers list for the
  user to place.

Keep the list on the map issue from the first ticket, never rebuilt at the end.

## Every brief contains

- The ticket link, the files to read first, and what is already ruled out.
- Setup the fresh worktree needs, as commands.
- The skills to use, by name.
- Acceptance items, each needing a named test or a receipt.
- Hard limits: no push, PR, merge, tag or stash; no pattern kills (`pkill`,
  `killall`), stop only your own processes by PID; no restart of shared
  services; no teardown command that touches shared state; cloud access
  read-only except the writes named in the brief; nothing in environments other
  than the ones named.
- Repo rules that agents break most: comment policy, commit format, no
  attribution lines, no infrastructure identifiers in committed files or client
  responses.
- For cloud mechanics: look up current docs and cite them, do not rely on memory.
- Report format: commits, a receipt per acceptance item, measured numbers,
  fixes with root cause and receipt, not verified, leftovers with their fate,
  open decisions, cost, cleanup done.

## Talking to the user

Write for someone who has not read the code or the agent reports. Each item
says what it is, why it matters to the product, and whether the user needs to
act (yes or no). Name things by what the user sees, not by internal names.
Post a short status after every round without being asked, leading with the
result. Answer the user's questions before continuing.

## Rules for you

- Do not fix code or run end-to-end checks yourself. Delegate, then review.
- You cannot message a running agent. A change of plan goes into the next round.
- Measure before you design. A number from a ticket is a claim until a real run
  confirms it.
- Treat automated security findings as valid until you can show otherwise, and
  fix them before the real run.
- When the user changes a decision mid-flight, fold it into the open ticket.
- If an agent has been silent for much longer than similar rounds took, check
  on it and tell the user what you found.

## Done

The map is done when every ticket is merged and closed, the map issue is
closed, no sub-issue is attached that was not worked, and the final report is
posted.

Final report: merged PRs and closed tickets; what was deployed where; what the
other environments still need; what was not verified; incidents; every
leftover with its fate (fixed in PR #n, ticket #n, needs your decision); open
decisions; cost; confirmation that worktrees, branches, temp files and test
resources are gone.
