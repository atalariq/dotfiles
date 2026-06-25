# Theme Unification — wana → everything (design)

**Date:** 2026-06-25
**Status:** Approved (brainstorm), pending implementation plan
**Scope:** Sub-project A of a larger dotfiles audit. Sibling sub-projects (own
specs): B = TTY/server multiplexer (tmux primary, herdr desktop-only), C =
matcha email module, D = AI-tools approval/permission unification, E =
housekeeping (espanso restart, TODO/PLAN cleanup, retire zed module).

---

## Goal

One ratified palette (`../wana`) drives **every theme-capable app** in this
machine's environment. wana is the **fixed default**; pywal and matugen remain
**opt-in dynamic** modes. The pipeline must keep working on a **bare TTY/server**
with no compositor and no Python/wana available at runtime.

## Decisions (locked during brainstorm)

1. **Generation lives upstream in wana.** Extend `wana/tools/gen.py` with a
   `render_<target>()` per app. wana stays the single source of truth; dotfiles
   only consumes. (Matches wana's own `TODO.md` porting roadmap.)
2. **dotfiles consumes via a vendoring sync script.** Generated theme files are
   **committed** into dotfiles module paths. No runtime dependency on wana or
   Python on a server.
3. **wana = fixed default; pywal + matugen = optional dynamic.** Dynamic
   generators never overwrite the vendored `wana-*` files.
4. **nvim stays everforest** for now; `wana.nvim` will be its own repo.
5. **zed dropped** from theme scope (no longer used); module retirement tracked
   as housekeeping (sub-project E).

---

## Architecture & contract

```
wana/schemes/wana-{dark,light}.yaml          ← source of truth (base24)
        │  wana/tools/gen.py  (render_<target> per app)
        ▼
wana/themes/<app>/wana-{dark,light}.<ext>    ← generated, committed in wana
        │  dotfiles/script/theme-sync  (runs gen.py, copies per manifest)
        ▼
config/app/<module>/.../themes/wana-{dark,light}.*   ← VENDORED + committed in dotfiles
        │  each app includes/imports its wana theme via a `wana-current.*` symlink
        ▼
.local/script/theme-switch {dark|light|toggle}  ← repoints symlinks, nudges live apps, sets TTY
```

**Properties:**

- **No runtime dependency.** Apps read committed static files. `theme-sync` is a
  _dev-time_ tool, run only when the palette changes.
- **Adding a target = 3 small steps:** a `render_<app>()` in wana's `gen.py`, one
  row in `theme-manifest.toml`, and one `include`/`import` line in the app config.
- **Single coupling point.** `theme-sync` + `theme-manifest.toml` are the only
  place the two repos touch. The contract is purely file-naming:
  `wana/themes/<app>/wana-{dark,light}.<ext>`.
- **Cross-repo flow.** wana PRs add renderers; dotfiles PRs add wiring + manifest
  rows.

---

## Target registry (tiered)

### Tier 1 — core (implement all)

| Target        | wana renderer                                | dotfiles wiring                                      | live-reload                |
| ------------- | -------------------------------------------- | ---------------------------------------------------- | -------------------------- |
| kitty         | `render_kitty` (exists)                      | `current-theme.conf` + `*-theme.auto.conf` → wana    | yes (`kitty @ set-colors`) |
| alacritty     | `render_alacritty` (TOML)                    | `import themes/wana.toml` (swap from noctalia)       | yes (native)               |
| TTY console   | `render_tty` (16× `\e]P` script)             | sourced at login when `$TERM=linux`                  | yes (re-emit seq)          |
| btop          | `render_btop` (`.theme`)                     | `themes/wana.theme` + `color_theme`                  | next launch                |
| yazi          | `render_yazi_flavor` (`flavor.toml`)         | `flavors/wana.yazi/`                                 | next launch                |
| bat           | `render_bat` (`.tmTheme`)                    | `BAT_THEME=wana` + `bat cache --build`               | next shell                 |
| delta         | `render_delta` (syntax-theme = bat's)        | gitconfig                                            | next launch                |
| fzf           | `render_fzf` (`--color` string)              | `FZF_DEFAULT_OPTS`                                   | next shell                 |
| starship/fish | `render_starship` (palette block)            | `palette = "wana"`                                   | next prompt                |
| herdr         | `render_herdr` (`[theme.custom]`)            | merge into `config.toml`                             | next launch                |
| pywal         | `render_pywal` (colorscheme JSON)            | add `wana-{dark,light}.json` colorschemes            | opt-in                     |
| noctalia      | `render_noctalia` (M3 JSON + terminal block) | `~/.config/noctalia/palettes/Wana.json` (new module) | yes (noctalia)             |
| lazygit       | `render_lazygit` (`wana.yml`)                | replaces rose-pine trio                              | next launch                |
| opencode      | `render_opencode` (JSON theme)               | swap from `nord.json`                                | next launch                |
| atuin         | `render_atuin` (theme block)                 | `config.toml`                                        | next launch                |

### Tier 2 — nice-to-have (implement if cheap; else log as follow-up)

rofi (`.rasi`), dunst, mako, gtk3 (`colors-custom-gtk3.css` analog).

### Deferred (owned elsewhere / out)

- **nvim** — stays everforest; `wana.nvim` is its own repo.
- **tmux** — `render_tmux` is written here so the target exists; **wiring** lands
  in sub-project B.
- **matcha** — themed when its module lands (sub-project C).
- **matugen** — dynamic wallpaper→Material-You engine for noctalia, not a static
  wana target. Stays as the dynamic mode (see below).
- **WM borders** (mango/niri/hyprland), **zed** — low payoff / unused; out.

---

## Light/dark switching

Most CLI apps cannot repaint a _running_ process. Design uses **`current`
indirection + nudge-on-switch**, not live magic everywhere.

- Each switchable app includes a stable `wana-current.*` that is a **symlink** to
  `wana-dark.*` or `wana-light.*` (generalizes what kitty already does with
  `current-theme.conf`).
- **`.local/script/theme-switch {dark|light|toggle}`**:
  1. repoints all `wana-current.*` symlinks to the chosen variant,
  2. **nudges live-reloaders:** kitty (`kitty @ set-colors`), alacritty (native),
     TTY (re-emit `\e]P` palette to active VTs), noctalia (its dark/light IPC),
  3. writes the active variant to `~/.cache/wana/variant`; login shells read it to
     set `BAT_THEME`, `FZF_DEFAULT_OPTS`, starship palette on next shell,
  4. apps without live reload (btop, lazygit, opencode, atuin, herdr) pick up
     `wana-current` on next launch — acceptable; the script `log`s which apps are
     next-launch-only so the gap isn't silent.

**Default & automation:**

- Boot default = **wana-dark** (per-machine override possible later).
- `night-theme-switcher` is **gutted of its pywal/nvim-remote internals** and
  becomes a thin caller: sunset → `theme-switch dark`, sunrise → `theme-switch
light`. Timer behavior kept; bespoke logic dropped.
- **Headless/server:** `theme-switch` runs without a compositor — skips the
  noctalia nudge, still sets kitty/alacritty/TTY/env.

---

## Dynamic generators (pywal + matugen) coexistence

Rule: **vendored `wana-*` files + `theme-switch` own the fixed path; pywal and
matugen are opt-in and never clobber the committed theme files.**

- **pywal** keeps templates, gains `wana-dark/light` colorschemes, but is **out of
  the default boot path**. `wal -i <wallpaper>` pushes colors **live** (e.g.
  `kitty @ set-colors`, cache files), not into `wana-current.*`. Re-pin with
  `theme-switch dark`.
- **matugen** stays noctalia's wallpaper-driven engine. Selecting the static
  `Wana.json` palette = fixed mode; wallpaper mode = dynamic mode. A
  noctalia-level toggle; no repo conflict.
- **kitty overlap fix:** kitty always `include`s `current-theme.conf` (wana
  symlink). Dynamic tools push via `kitty @ set-colors` (live, fileless) instead
  of swapping the include — exactly one include path, no file fight.

---

## Module layout & files

**New/changed in dotfiles:**

- `script/theme-sync` — dev-time: runs `wana/tools/gen.py`, copies outputs per
  manifest; supports `--check` (drift guard).
- `script/theme-manifest.toml` — single declarative map both scripts read:
  `target → wana-output-path → dotfiles-dest → reload-method`.
- `config/misc/scripts/.local/script/theme-switch` — runtime command on `$PATH`.
- Vendored themes in each module's existing themes dir (kitty `themes/`,
  alacritty `themes/`, btop `themes/`, yazi `flavors/`, lazygit, etc.).
- **New module** `config/desktop/noctalia/` for `Wana.json` → add to
  `profiles/laptop.json`.
- `night-theme-switcher` gutted into a thin `theme-switch` wrapper.
- Docs: update `CONTEXT.md`, `AGENTS.md`, `CLAUDE.md`, `README.md` per the
  Standing Rule, incl. a "How to add a theme target" section.

**wana repo (lands first, separate commits):** renderers + `tools/templates/<app>`
for alacritty, tty, btop, yazi, bat, delta, fzf, starship, herdr, pywal,
noctalia, lazygit, opencode, atuin, tmux; extend `test_gen.py`.

---

## Verification

- **wana:** `gen.py --check` (no stale committed themes); reuse
  `test_gen.py`/`test_drift.py`; `color.py contrast <fg> <bg>` on new targets for
  WCAG sanity.
- **dotfiles:** `theme-sync --check` asserts vendored copies match wana output
  (CI-able drift guard); `setup.sh --dry-run use desktop/noctalia`.
- **Switch:** `theme-switch dark|light` idempotency + visual check; verify TTY
  palette on a real VT (Ctrl+Alt+F3); confirm headless path skips noctalia
  cleanly.

---

## Dependencies & sequencing

1. wana: land renderers + templates + tests (Tier 1 targets).
2. dotfiles: `theme-sync` + `theme-manifest.toml` + `theme-switch`.
3. dotfiles: per-app wiring (Tier 1), `current` symlinks, gut
   `night-theme-switcher`.
4. dotfiles: new noctalia module + profile update.
5. Tier 2 targets if cheap; otherwise log as follow-ups.
6. Docs update (Standing Rule).

## Out of scope (explicit)

nvim theming, tmux/matcha wiring, AI-tools approval cleanup, zed module
retirement — each owned by its own sub-project spec.
