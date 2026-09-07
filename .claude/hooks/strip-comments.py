#!/usr/bin/env python3
import json
import os
import sys

HASH = {".py", ".sh", ".zsh", ".bash", ".rb", ".yaml", ".yml", ".toml", ".tf", ".tfvars"}
SLASH = {".js", ".ts", ".jsx", ".tsx", ".mjs", ".cjs", ".go", ".rs", ".c", ".h", ".cpp", ".hpp", ".java", ".swift", ".kt", ".scala"}
KEEP = ("#!", "# type:", "# noqa", "# ruff", "# fmt:", "# pylint", "# pragma", "# shellcheck",
        "// eslint", "// @ts-", "// prettier", "// biome", "//go:", "//nolint", "// ponytail:", "# ponytail:")


def strip(text, marker):
    out = []
    for line in text.split("\n"):
        s = line.lstrip()
        if s.startswith(marker) and not s.startswith(KEEP):
            continue
        out.append(line)
    return "\n".join(out)


def main():
    d = json.load(sys.stdin)
    ti = d.get("tool_input", {})
    ext = os.path.splitext(ti.get("file_path", ""))[1].lower()
    marker = "#" if ext in HASH else "//" if ext in SLASH else None
    key = "new_string" if "new_string" in ti else "content" if "content" in ti else None
    if not marker or not key:
        return
    cleaned = strip(ti[key], marker)
    if cleaned == ti[key] or not cleaned.strip():
        return
    ti[key] = cleaned
    print(json.dumps({"hookSpecificOutput": {
        "hookEventName": "PreToolUse",
        "permissionDecision": "allow",
        "updatedInput": ti,
    }}))


main()
