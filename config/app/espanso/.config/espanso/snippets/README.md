# LLM Prompt Snippets

Reusable, platform-agnostic prompt snippets. Built to paste into any chat
or coding agent (Claude, ChatGPT, Gemini, CLI agents). Copy the body, fill
the input slot at the bottom, send.

## Two modes

Each snippet assumes one of:

- **Blind (webchat)** — no tool/filesystem access. The model reasons only
  from what you paste. These end with a paste marker (`Input:`, `[PASTE]`)
  and never tell the model to "explore" or "run" anything. Blindness is
  intentional, so they work the same across platforms.
- **Tooled (coding agent)** — the agent has repo/tool access and is told to
  explore and verify before asserting. Only use these where an agent can
  actually read the codebase.

When adding a snippet, decide its mode first — it changes the wording.

## Relationship to `~/Repos/skills`

That repo is an Agent Skills collection (agentskills.io spec): **agent-invoked**,
interactive, often tool-aware. These snippets are **human-triggered** (Espanso
`:ai`), one-shot, paste-into-any-chat. Same idea can live in both as long as the
ergonomics differ on purpose. Canonical home is decided **per trigger**, not per
concept — don't collapse them.

| Concept                     | Here (snippet, paste)                          | skills (skill, invoked)                         | Status                           |
| --------------------------- | ---------------------------------------------- | ----------------------------------------------- | -------------------------------- |
| Decide between options      | `decide.md` (one-shot, richer output)          | `decide` (interactive)                          | Both — different trigger         |
| Pause/resume work           | `checkpoint.md` / `resume.md` (copy-able text) | `session-save` / `session-load` (writes a file) | Both — different mechanism       |
| `grill-me.md` vs `ideation` | drills an existing plan                        | validates an idea to build                      | Not overlapping — different jobs |

Before adding a snippet that smells like an existing skill, check this table.
If the only difference would be format, fold it into the skill instead.

## Index

| File                      | Mode   | What it does                                                          |
| ------------------------- | ------ | --------------------------------------------------------------------- |
| `audit-codebase.md`       | tooled | Audit a repo + review your proposals, compile a ranked follow-up list |
| `review.md`               | blind  | Strict senior review of a plan/code chunk, with a verdict             |
| `decide.md`               | blind  | One-shot comparison of options with a committed recommendation        |
| `unstuck.md`              | blind  | Step back when going in circles: continue / reset / pivot             |
| `grill-me.md`             | blind  | Relentless one-at-a-time interview to pin down a plan before building |
| `cli-prompt.md`           | blind  | Generate an actionable prompt for a CLI coding agent                  |
| `checkpoint.md`           | blind  | Capture a state checkpoint for handoff to another model               |
| `resume.md`               | blind  | Resume work from a state checkpoint                                   |
| `humanization.md`         | blind  | Full academic-essay humanization prompt                               |
| `humanization-concise.md` | blind  | Compact version of the above                                          |
| `safe-md.md`              | blind  | Force copy-safe Markdown output (no wrapping fence)                   |

## Conventions

- One file = one prompt. Name in kebab-case after the job it does.
- Open with an imperative line stating the job in one sentence.
- Use `## headers` only when the prompt is long; short ones stay flat.
- End with the input slot: `Input:`, `Task:`, `Checkpoint:`, or `[PASTE]`.
- Keep it tight. Cut filler; every line should earn its place.
- Bias toward leverage and the smallest change — don't write prompts that
  invite maximalist rewrites or overengineering.
