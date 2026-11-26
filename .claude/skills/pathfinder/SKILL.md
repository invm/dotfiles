---
name: pathfinder
description: Makes any ticket ready for trailblazer. Takes an issue (vague, a single change, a checklist, or several changes in one) or a loose request, resolves what it leaves open, and rewrites it in place as a ready ticket, or as a map when it holds independent changes. Use before trailblazer on anything that is not already a ready ticket or map, or when the user says "pathfinder".
---

# Pathfinder

Argument: an issue URL or number, or a request in words. You write the
ticket; you build nothing. The output is a **ready** ticket: one a dispatcher
can build, verify and merge without asking the user anything.

A ticket that already has every section of "Ready ticket" filled is ready:
say so and stop.

## 1. Read

The ticket with its comments, the issues it links, the repo's CLAUDE.md, and
the code it names. A request in words with no issue: search the tracker for an
existing issue first, create one only when none exists.

## 2. Challenge

You maintain this codebase after the ticket merges. Before shaping, judge the
ticket as its maintainer, from the code you read.

Run the challenge as one subagent on the strongest model available (Opus or
above), whatever model the session runs. Brief it with the ticket and the
files to read, never with your own opinion of the ticket. It returns
objections, each with its receipt and alternative, or none.

| Question | Object when |
|---|---|
| Does it need to exist? | The code or a setting already does it, or the need is speculative |
| Is it the root? | The ticket names a symptom and the cause sits elsewhere, or sibling code paths carry the same fault |
| Does it fit? | It adds a second way to do what the codebase already does one way, or a special case for one caller where a general change costs the same |
| What does it leave behind? | It replaces code without deleting it, or adds a dependency, flag or abstraction with one user |

Object only when your alternative changes what gets built. An objection
carries a receipt (`file:line` or a command with its output) and the
alternative you would build instead. It goes in the batch of questions in
step 4, recommendation first, and the owner's answer goes under Decisions.
This is the one point where disagreement stops the work: once the ticket is
ready, trailblazer does not ask. A choice of how to build it (which helper to
reuse, which pattern to follow) is not an objection: write it under Fit.

## 3. Shape

| The ticket holds | Shape |
|---|---|
| One feature area (same screen, endpoint, command, or module), however many checkboxes | One ticket, one PR. Edit it in place. Keep it whole |
| Changes in separate areas that can merge on their own | The issue becomes the map: goal, order, one child issue per area. Each child is a ready ticket |
| A decision with nothing to build until the owner makes it | Not ready. Write the decision and its options on the issue, tell the user, stop |

Split by area, never by size. A long checklist in one area stays one ticket.

## 4. Resolve

Every open point gets an answer from, in this order: the ticket and its
comments, linked issues, the repo's docs, the code, a command you run. A
reversible choice nothing answers takes the simplest option, recorded under
Decisions as a default.

Gather evidence before any question reaches the user: read the callers, run
the command, check the history (`git log`, the linked issues). A question
arrives with what you checked and what you found. An objection whose receipt
you cannot reproduce is dropped, not asked.

Ask the user only your objections from step 2 and what is irreversible, outward-facing, removes behavior a
user can see, or is the owner's call (wording, pricing, scope). One batch,
each question with your recommendation first. Nothing qualifies: ask nothing.

When the real cost dwarfs the ask (a new dependency, a schema change, a
third-party patch, new credentials), write the cost on the issue and ask
before marking it ready.

## 5. Write

Edit the issue body in place. Keep the owner's own wording and checkboxes;
sharpen them and add what is missing. When an answer you resolved makes one
of their items wrong or moot, put the edit or deletion in your batch of
questions with the reason; change it only after the user agrees.

### Ready ticket

```markdown
## Goal
<one or two lines: what changes, as the user of the product sees it>

## Acceptance
- [ ] <observable result> (check: <test name, command, or screenshot of which screen>)

## Area
<screens, endpoints, commands or modules this ticket owns>

## Touches
<files or directories the change will likely edit, from reading the code>

## Fit
<existing code the change reuses or extends, the pattern it follows, and what it deletes, each with file:line>

## Needs
<environment, test data, sign-ins, keys, tools the build and the check need; "nothing beyond local setup" when true>

## Depends on
<issues that must merge first, or "none">

## Decisions
- <choice>: <answer> (<owner | default | source link>)
```

A map carries Goal, the ordered list of child issues, and Decisions; each
child carries the full block.

Ready means: every acceptance item names its check, every section is filled,
and no question is left open on the issue.

## 6. Hand off

Reply with the issue link, its shape (ticket or map), the defaults you took,
and anything only the user can do. When trailblazer invoked you, return to it.
