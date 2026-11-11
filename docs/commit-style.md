# Commit style

This is the single source for how commit messages are written in this
repository, and in the other personal-but-public projects that copy it.

The shape comes from the way Linus writes in his own trees: a conventional
header, then a body that tells the story of the change instead of replaying
the diff. A commit is read twice - once by a reviewer today, and once by
whoever is hunting for the reason a line exists two years from now. The
second reader is the one this document is for.

## Shape

```text
type(scope): imperative summary

The problem, in the words of whoever hit it. What the obvious fix was,
and why the patch does something else when it does.

What the change actually does about it, and which part a reviewer should
look at first.

Refs: dotfiles-<id>
```

- **Header**: Conventional Commits, imperative, no trailing period, at most
  72 characters. `feat`, `fix`, `refactor`, `perf`, `docs`, `test`, `build`,
  `ci`, `chore`, `revert`.
- **Body**: wrap near 72 columns. Paragraphs, not bullet soup.
- **Footer**: `Refs: <bead-id>` when the change belongs to an issue.
  `Co-authored-by:` only when someone materially wrote the change. Routine
  agent sessions belong in Beads, not in the trailer.

## What the body says

Write it as if explaining the change to yourself in six months:

- What was wrong or missing, and how it showed up.
- What you tried first, and why it was not the answer - this is usually the
  most useful paragraph in the commit.
- What the patch does, and what trade-off it accepts.
- What a reviewer or future maintainer should verify, if it is not obvious.

Do not narrate files. `git show --stat` already does that. A body that reads
"update X.nix and Y.nix" has told the reader nothing they could not see.

First person is fine. This is a personal tree; pretending otherwise makes the
history sound like a changelog nobody asked for. Prefer plain sentences over
marketing words: "this fixes the crackle" beats "this delivers a robust audio
experience".

## It is public, but it is not a product

Visibility is not a reason to add ceremony. No release-note voice, no
capitalised benefit lists, no thanking imaginary stakeholders.

What visibility does require:

- Keep secrets out: no tokens, private hostnames, or receipt paths.
- Keep private context out: no budgets, no session transcripts, no medical or
  travel details that happened to be true the day the commit was written.
- Assume a stranger can read it without your notes and still follow the
  decision.

## Examples

Good - it explains the decision and the thing that was tried first:

```text
fix(audio): stop forcing game-sized buffers on every client

The gaming module used to hand every PipeWire client a 64-sample quantum.
On an idle machine that is harmless and buys latency; with Android Studio
and a browser resident it is a different story, because 1.3 ms is shorter
than a JVM pause, and an underrun is what "brebet" actually was.

I kept the realtime module, since RTKit was already granting it correctly.
What changed is the graph: 1024 samples by default, 256 minimum so a game
can still ask for low latency, and 4096 maximum so a busy box has somewhere
to breathe.
```

Good - it says why the shape of the patch is unusual:

```text
feat(clients): pair the ThinkPad with Syncthing

I deliberately did not declare the device list or folders in Nix. Those
change whenever I pair a new phone, and a declarative list would silently
overwrite the runtime state that the UI writes. The module enables the
service; the identity and folders stay where Syncthing expects them.
```

Bad - a diff replay:

```text
feat(clients): update apps.nix

Remove jellyfin-desktop, add koreader.
```

## Using this elsewhere

Copy this file into the other repositories instead of inventing a second
convention. The dotfiles repository is the source; when this document
changes, the copies follow.

Wana and any other personal project adopt the same shape. Nothing here is
Nix-specific: the header carries the classification, the body carries the
reasoning.
