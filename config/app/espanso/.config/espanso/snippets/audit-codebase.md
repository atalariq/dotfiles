Audit this codebase as a pragmatic senior engineer, then compile a
prioritized set of follow-up proposals I can act on next.

Explore the repo to ground every claim in real code. Verify before you
assert — don't report a bug or gap you haven't traced to a file:line.
Read AGENTS.md / CLAUDE.md / README first and respect existing conventions.

## Scope

The work I just finished:
[DESCRIBE THE WORK / BRANCH / DIRS, or "the current diff vs main"]

My own proposals to review:
[LIST YOURS, or "none"]

## Do

1. Map — what the code does and its shape. Brief, no line-by-line recap.
2. Find — concrete bugs, gaps, fragility, duplication, missing tests,
   inconsistency, and overengineering. Each with a file:line and why it matters.
3. Review my proposals — for each: keep / refine / drop, with a one-line reason.
   If it's vague, sharpen it into something concrete. If it needs options
   (e.g. a naming decision), generate a few and recommend one.
4. Compile — merge your findings and my proposals into ONE ranked list.

## Rank by leverage (impact vs effort), not ambition

Prefer the smallest change that fixes the root cause.
Flag overengineering, not just missing abstraction.
Explicitly skip work that isn't worth it — say why.

## Output

A proposals doc. Each item:

- title
- type: bug / improvement / docs / naming / test / chore
- priority: P0 blocker / P1 / P2
- effort: S / M / L
- what & why (2-3 lines)
- a ready-to-paste prompt for a coding agent to execute it

Save it to a new file (don't overwrite existing proposals) or print it.
Don't implement anything yet — this pass is audit and planning only.
