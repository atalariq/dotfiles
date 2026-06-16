# Yazi Notes

Short doc for the repo-managed Yazi setup.

## Philosophy

Keep Yazi good at file navigation first.

Bias toward:
- fast navigation
- stable previews
- low external dependency drama

Avoid turning it into a plugin circus where one missing binary breaks half the UX.

## Current split

### Core
These are worth keeping because they improve daily navigation or preview without too much drama:
- `mediainfo`
- `preview-sqlite`
- `bypass`
- `open-with-cmd`
- `spot`
- `spot-image`
- `spot-audio`
- `spot-video`

### Optional power-user helpers
Nice when available, but not essential to basic file-manager use:
- `starship`
- `save-clipboard-to-file`
- `mount`
- `chmod`
- `ripdrag` keybinding

## Deliberately removed
These were pruned because they added fragility relative to the value they gave:
- `exifaudio`
- `office`
- `preview-typst`
- `ouch`
- `.m3u/.m3u8 -> code` handoff

Reasons:
- missing binaries on this machine
- duplicated preview responsibilities
- optional workflows pretending to be core UX

## Current dependency assumptions

### Expected for the current core setup
```bash
yazi
ya
mediainfo
ffmpeg
magick
fzf
fd
rg
zoxide
jq
file
xxhsum
```

### Optional but referenced by some keymaps/plugins
```bash
ripdrag
udisksctl
starship
wl-copy
wl-paste
sqlite3
```

## Keymaps worth remembering

### Core flow
- `s` search by name via `fd`
- `S` search content via `rg`
- `Z` jump with `fzf`
- `z` jump with `zoxide`
- `L` bypass single-child dirs forward
- `H` bypass single-child dirs backward
- `Enter` open interactively
- `Shift-Enter` open with prompted command

### Optional actions
- `g D` drag file via `ripdrag`
- `g m` mount devices
- `g P` save clipboard to file
- `g M` toggle mediainfo metadata
- `c m` chmod selected files

## Refactor rule going forward

Before adding a Yazi plugin, ask:
1. does it improve navigation or preview every week?
2. does it require another flaky external binary?
3. does it overlap an existing plugin?
4. can the same job be done with `open-with-cmd` or shell?

If the answer is mostly “rarely used” or “more dependencies”, keep it out.
