---
name: design-variations
description: On demand only. Explores a new screen or section as wireframes in several deliberately different layouts, then merges the parts the user picks. Use when the user says "design variations", "explore layouts" or "/design-variations". Never run it as part of a normal build.
---

# Design variations

1. Read the project's design rules first (improved-disco console: `.claude/skills/ui-review/SKILL.md` § Judge; marketing-site: `design.md`). Every variation obeys them.
2. Ask the user for references: screenshots, comparable products, past work they like. Name two comparable products that do the same job and the layout pattern they share.
3. Wireframes only: grey boxes, real copy, existing components. No new colors or fonts.
4. Make 10 variations unless the user names fewer. Make them differ in structure, order, density and entry point, not only spacing. One line per variation says what makes it different.
5. Render each to a screenshot in `/tmp/design-variations` and show them side by side. Nothing from this step is committed.
6. Build one merged version from the parts the user picks. Then the normal builder and the project's visual review take over.
