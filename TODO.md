# dotfiles — TODO

## Espanso prompt snippets (moved in, not yet committed)

LLM prompt snippets were moved from `~/Grimoire/Meta/llm/snippets` into
`config/app/espanso/.config/espanso/snippets/` so they get backed up here.
`~/Grimoire/Meta/llm/snippets` is now a symlink to the canonical copy.
Grimoire is not a git repo, so this dir is the only backup.

- [x] Commit the move (scoped — repo has unrelated dirty files, don't `add -A`):

  ```bash
  git add config/app/espanso/.config/espanso/snippets \
          config/app/espanso/.config/espanso/match/snippet.yaml
  git commit -m "feat(espanso): move llm prompt snippets into espanso config for backup"
  ```

- [ ] `espanso restart` if the `:ai` picker doesn't pick up the new path.

## Repo hygiene

- [x] Triage the ~20 unrelated modified files in the working tree
      (nvim, fish, mango, codex, yazi, git, etc.) — commit or discard.

## Follow-ups (from snippets audit)

- [x] Resolve concept drift between `snippets/` and `~/Repos/skills`.
      Outcome: no deletion — overlaps are intentional (snippet = paste/one-shot,
      skill = invoked/interactive). `grill-me` vs `ideation` was not actually an
      overlap. Boundary documented in the snippets README ("Relationship to
      ~/Repos/skills"). Rule: canonical home is per trigger, not per concept.
