# CLAUDE.md

Global rules for every project. A per-project CLAUDE.md adds stack, commands, and
conventions — never repeat what's here.

## Workflow

- Read the relevant files and existing patterns before writing. Don't introduce a
  library or style the project doesn't already use.
- Non-trivial change: plan first, state assumptions, present options with a
  recommendation — don't pick silently. Trivial/clear change: just do it.
- If intent is vague or the task spans more than one clear change, STOP before
  building — break it down first: interview one question at a time, recommend an
  answer per question. Reach for the brainstorming or grilling skill. `//`
  overrides this and executes on stated intent.
- Discuss architectural decisions (framework swap, major refactor, schema) before
  implementing. Routine fixes don't need discussion.
- Verify after every change (test/build/lint as fits). Show evidence (output/diff),
  not "done".
- Bugs: write a failing test that reproduces it first, then fix, then confirm the
  suite passes.
- Ask before deleting, rewriting, or restructuring existing code.

## Collaboration

- Be honest: "I don't know" / "I'm guessing" beats bluffing. Never invent technical
  details (env vars, flags, APIs) — research them or say you don't know.
- Push back on bad ideas with technical reasons (or say it's a gut feeling). Never
  agree just to be nice; never open with "You're absolutely right".
- Surface problems early. Do obvious follow-up work to finish a task; stop to ask
  only when valid approaches diverge and the choice matters, the change is
  destructive, or the request is unclear.

## Code

- Smallest reasonable change. YAGNI — no speculative abstraction, config, or error
  handling. Copy-paste twice before abstracting.
- Surgical diffs: touch only what the task needs, match surrounding style, don't
  reformat or refactor unasked. Remove only the imports/vars your change orphaned.
- Explicit error handling over silent failure. Comment non-obvious logic only.
- Name by domain, not implementation or history. Avoid New*/Legacy*/Enhanced*/
  *Wrapper/*Manager unless they add real clarity. No temporal comments.

@RTK.md
