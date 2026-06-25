# Theme Unification A2 — remaining CLI/TUI targets (design)

**Date:** 2026-06-25
**Status:** Approved (brainstorm), pending implementation plan
**Depends on:** A1 (`2026-06-25-theme-unification-wana-design.md` + the shipped
`gen → theme-sync → theme-switch` pipeline).
**Scope:** Sub-project A2 of theme unification. Extends the A1 pipeline to the
remaining portable CLI/TUI targets. Desktop GUI apps are explicitly **not** here
(owned by Noctalia — see Ownership).

---

## Goal

Bring the rest of the terminal/CLI/TUI tools under the wana palette using the
A1 pipeline (wana `gen.py` renderers → `theme-sync` vendoring → `theme-switch`
wiring). Targets: **pywal scheme, fzf, herdr, delta, bat, starship, btop,
lazygit, atuin, opencode, yazi**. Everything must keep working on a bare
TTY/server (no compositor, no runtime wana/Python dependency).

## Decisions (locked during brainstorm)

1. **bat/delta:** generate a **base16 `.tmTheme`** from the wana scheme (richer
   syntax colors than `ansi`). delta rides bat via `BAT_THEME` (no explicit
   `syntax-theme`).
2. **yazi:** generate the full `flavor.toml` from a template (single source of
   truth), accepting it as the heaviest renderer.
3. **opencode:** ship a dedicated `wana.json` theme (not `"theme":"system"`).
4. **starship:** a single **variant-neutral** `[palettes.wana]` (no dark/light
   switch) — matches the current single-palette setup; avoids duplicating the
   whole `starship.toml`.
5. **Packaging:** one A2 plan; **yazi is its own final task** so it doesn't block
   the cheap wins.
6. **Ownership split by reach:** the **wana pipeline owns portable CLI/TUI**
   (this spec + A1's kitty/alacritty/tty); **Noctalia owns desktop-only GUI**
   (gtk/qt/compositor/zathura/telegram/…) via its templating, fed by the wana
   palette in A3. **Disable Noctalia's overlapping templates** + clean the
   artifacts it wrote — folded into A2 (see Noctalia Cleanup).

---

## Why not let Noctalia template these apps?

Noctalia's templating is a wal/matugen-class engine, but it's the wrong owner
for A2 targets: (a) it's a Quickshell desktop shell — **not running on a bare
TTY/server**, so it can't theme bat/btop/fzf/yazi there, which is the whole point
of this effort; (b) it renders into `~/.config/<app>/…`, which for stow-symlinked
apps **writes through the symlink into the repo working tree** (the stray
`themes/noctalia.conf` in the kitty dir is exactly this). So a static pipeline is
required regardless, and the two systems must not own the same app.

---

## Architecture (reuses A1)

Same pipeline. Each target gets a `render_<app>()` in `wana/tools/gen.py`. New
in A2: targets wire into the live system in **four classes**, plus one small new
consumer for env-based switching.

### Wiring classes

**Class A — symlink target** (A1 pattern: `wana-current.*` symlink + reload):
`btop`, `yazi`, `lazygit`, `atuin`, `opencode`. Full A1-style manifest row;
`theme-switch` repoints the symlink + nudges the app.

**Class B — env-variant** (shell exports from `~/.cache/wana/variant`): `bat`,
`fzf`. Both variants vendored; a shell snippet sets `BAT_THEME=wana-$variant`
and the variant's fzf `--color` string. **delta** rides bat for free (no explicit
`syntax-theme` → honors `BAT_THEME`; confirm `.gitconfig`/lazygit pagers don't
override it — lazygit uses `delta --dark`, which must drop `--dark` or it forces
dark).

**Class C — in-place generated block** (pasted between sentinel markers in an
existing config): `starship` (`[palettes.wana]` + `palette="wana"`, single
variant) and `herdr` (`[theme.custom]`). Regenerated from `gen.py` and replaced
between sentinels; not a `theme-switch` row.

**Class D — sync-only availability** (vendored, not switched — the dynamic mode):
`pywal` `wana-{dark,light}.json` colorschemes, used via `wal --theme wana-dark`.

### Manifest extension

One new convention: **`home_current = -`** marks a **sync-only** row —
`theme-sync` still vendors both variants (it only reads cols 1-3), but
`theme-switch` **skips** it (no symlink, no reload). Class B and D rows use `-`.
Class A rows are full A1-style rows. Class C targets are **not** manifest rows.

### New infra: env-variant consumer

A1 wrote `~/.cache/wana/variant` but nothing read it. A2 adds:

- `config/app/fish/.config/fish/conf.d/50-wana-theme.fish` (+ a POSIX equivalent
  sourced from `.profile`/bash login) that reads the variant (default `dark`) and
  exports `BAT_THEME=wana-$variant` and appends the variant's fzf `--color` string
  to `FZF_DEFAULT_OPTS`.
- Switching for env targets takes effect on **next shell** (consistent with A1).

---

## Target registry

| Target   | Class | wana renderer → output                                                  | dotfiles wiring                                                                                       |
| -------- | ----- | ----------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------- |
| pywal    | D     | `render_pywal` → `themes/pywal/wana-{v}.json`                           | vendor into `~/.config/wal/colorschemes/{dark,light}/wana.json`; `home_current=-`                     |
| fzf      | B     | `render_fzf` → `themes/fzf/wana-{v}.opts` (a `--color=…` string)        | env snippet reads variant; `home_current=-`                                                           |
| herdr    | C     | `render_herdr` → `themes/herdr/wana-{v}.toml` (`[theme.custom]`)        | replace block in `config/app/dev-tools/.config/herdr/config.toml` between sentinels                   |
| bat      | B     | `render_bat` → `themes/bat/wana-{v}.tmTheme`                            | vendor into `~/.config/bat/themes/`; `BAT_THEME=wana-$variant`; `bat cache --build`; `home_current=-` |
| delta    | B     | — (rides bat)                                                           | ensure no `syntax-theme` override; fix lazygit `delta --dark` pager                                   |
| starship | C     | `render_starship` → `themes/starship/wana.toml` (palette block, single) | replace noctalia palette block in `starship.toml` between sentinels; `palette="wana"`                 |
| btop     | A     | `render_btop` → `themes/btop/wana-{v}.theme`                            | `themes/wana.theme` + `color_theme="wana"`; current-symlink                                           |
| lazygit  | A     | `render_lazygit` → `themes/lazygit/wana-{v}.yml` (`gui.theme` block)    | merge into config / include; current-symlink                                                          |
| atuin    | A     | `render_atuin` → `themes/atuin/wana-{v}.toml`                           | vendor into atuin `themes/`; `theme.name="wana"`; current-symlink                                     |
| opencode | A     | `render_opencode` → `themes/opencode/wana-{v}.json`                     | vendor into opencode `themes/`; `"theme":"wana"`; current-symlink                                     |
| yazi     | A     | `render_yazi` → `themes/yazi/wana-{v}.toml` (full flavor)               | `flavors/wana.yazi/`; `[flavor]` use; current-symlink — **isolated final task**                       |

Notes:

- **bat both variants** are real files in `~/.config/bat/themes/` named
  `wana-dark.tmTheme` / `wana-light.tmTheme`; `BAT_THEME` selects — no symlink.
- **lazygit** currently has no `gui.theme` block in `config.yml`; the wana block is
  added there (or via a current-symlinked theme file the config references).
- **starship** palette must define every name the existing `format` strings use
  (standard `red/green/blue/...` + Catppuccin-compatible extended names +
  text/surface shades — mirror the current `[palettes.noctalia]` key set).

---

## Noctalia cleanup (folded into A2)

1. **Disable overlapping templates** in `~/.local/state/noctalia/settings.toml`
   `[theme.templates]`:
   - `builtin_ids`: remove `"alacritty"`, `"btop"`, `"kitty"`, `"starship"`.
     Keep `"cava"`, `"gtk3"`, `"gtk4"`, `"mango"`, `"niri"`, `"qt"` (desktop —
     Noctalia keeps owning them).
   - `community_ids`: remove `"yazi"`. Keep the rest.
   - This is a live runtime-state edit (not stow-tracked); document it. A3 may
     later manage Noctalia config properly.
2. **Remove the now-unused noctalia artifacts** from the repo (these were
   Noctalia template outputs; with the templates disabled they won't regenerate):
   - `config/app/kitty/.config/kitty/themes/noctalia.conf`
   - `config/app/alacritty/.config/alacritty/themes/noctalia.toml`
   - `config/app/system-tools/.config/btop/themes/noctalia.theme`
   - `config/app/yazi/.config/yazi/flavors/noctalia.yazi/`
   - the noctalia palette block in `starship.toml` (replaced by wana)
3. Each removal pairs with its app's wana wiring switch (btop `color_theme`,
   alacritty already on wana from A1, yazi flavor, starship palette).

---

## Sequencing (one plan)

1. **Trivial / quick wins:** pywal scheme; fzf `--color` + env consumer; herdr
   block; delta verification (drop lazygit `--dark`).
2. **Low/medium:** bat tmTheme + `BAT_THEME` env; lazygit `gui.theme`; atuin
   theme; starship palette block.
3. **Medium:** btop theme; opencode theme.
4. **Heavy (isolated final task):** yazi full flavor.
5. **Cleanup:** disable Noctalia overlapping templates; remove noctalia artifacts.
6. **Docs:** update AGENTS/CONTEXT/README target list; `theme-manifest` grows
   the new rows.

Each renderer follows the documented "How to Add a Theme Target" recipe: write
`render_<app>()` + `tools/templates/<app>` + a `test_gen.py` assertion in wana;
add a `theme-manifest` row (or in-place wiring for Class C); `theme-sync`; wire
the app; `theme-switch` verify.

---

## Verification

- **wana:** `gen.py --check` clean; per-renderer `test_gen.py` assertions
  (each output has its expected keys / parses as valid TOML/JSON/XML);
  `color.py contrast` spot-checks on fg/bg pairs.
- **dotfiles:** `theme-sync --check` drift guard; `theme-switch dark|light`
  repoints Class A symlinks; open a fresh shell to confirm `BAT_THEME` /
  `FZF_DEFAULT_OPTS` reflect the variant; launch each app once and eyeball.
- **delta:** `git diff` in a repo renders via bat's wana theme; lazygit diff view
  matches.
- **Noctalia:** after disabling templates and a theme change, confirm Noctalia no
  longer rewrites kitty/alacritty/btop/starship/yazi.

---

## Out of scope (explicit)

Desktop GUI theming (gtk/qt/compositor/zathura/telegram/cava/discord/…) → Noctalia
templating, configured in **A3**. nvim (everforest, `wana.nvim` later). tmux/matcha
(sub-projects B/C). zed retirement + stale README rows (sub-project E).
