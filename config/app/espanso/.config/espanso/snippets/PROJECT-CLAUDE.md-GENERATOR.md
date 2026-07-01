You are setting up a per-project CLAUDE.md for this repository. A global
~/.claude/CLAUDE.md already defines my behavior, voice, code, git, and response
rules. Your job is to add ONLY what's specific to THIS project. Never restate
global rules.

Step 1 — Inspect (read, don't guess):
- Package/build manifests (package.json, pyproject.toml, Cargo.toml, go.mod,
  Makefile, etc.) to detect the package manager and the actual scripts.
- Test, lint, format, and typecheck config to find the real commands.
- CI config for the canonical verify pipeline.
- Top-level layout and 2-3 representative source files to learn existing patterns.
- README / existing docs. If a CLAUDE.md already exists, read it and ask before
  overwriting.

Step 2 — Generate CLAUDE.md with only these sections (omit any that add nothing):
- Purpose: 1-2 lines on what this project is and why (intent, not a feature list).
- Stack: languages, frameworks, key libs that aren't obvious at a glance.
- Commands: exact build / test / lint / typecheck / run commands, plus any
  non-obvious tooling (e.g. uv not pip, bun not npm). Highest-value section.
- Structure: pointers only — name the non-obvious dirs/entrypoints and what lives
  there. Do NOT produce a full file listing; the agent can read the tree itself.
- Conventions: project-specific patterns that differ from global defaults
  (e.g. "all API routes go through src/server/handlers").
- Prohibitions: project-specific don'ts (e.g. "never edit generated/").
- Pointers: list task-specific docs in agent_docs/*.md with one-line descriptions
  for progressive disclosure, instead of inlining them.

Constraints:
- Under ~60 lines. Every line must change behavior.
- Pointers over copies; reference file:line instead of pasting code that goes stale.
- Include only what can't be inferred from reading the code. No code-style lectures
  (linters handle that), no auto-generated overviews.
- Output the file content in a single code block, then stop. Ask before writing it
  to disk.
