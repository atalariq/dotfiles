# Repository working rules

The owner's original `config/app`, `config/desktop/mango`, and `config/misc`
files are authoritative. Preserve their themes, keybindings, functions and
plugins. Mango is the only selected compositor. `apps/noctalia` contains new
Noctalia v5 preferences; `apps/manifest.json` owns mappings and package selection.
`hosts/<name>/host.json` owns current host selection. `profiles/` is retained
as the original module inventory, not an input to the new CLI.

For deployment changes read `docs/dotfiles-v1.md`; for the migration requirements
read `docs/migrate-to-nix.spec.md` together with the owner's later instructions.
The approved scope includes ThinkPad integration and Laravel/Android shells.
Use `./dot build` for filtered build-only validation. Preserve the captured
hardware configuration and stateVersion. Activation requires owner approval;
keep greetd.restartIfChanged=false to preserve the running graphical session.

The CLI and Home Manager share `bootstrap/dot.py` validation/link ownership.
After changing that boundary run `python3 -B -m unittest discover -s tests -v`.
Native links resolve to the live checkout: inspect before editing. Runtime
state and credentials stay outside deployment. Back up conflicts and prove
ownership before retiring deployed links. Keep rollback backups outside Git.

For layout/module/command changes update README.md, CONTEXT.md and this file.
When replacing native files from external storage, keep manifest source paths
stable; add mappings for new files when the parent is not a directory link.

## How to Add a Theme Target

The wana palette drives app theming through a generate → vendor → switch pipeline.

1. **wana repo:** add `render_<app>()` + `tools/templates/<app>` in `wana/tools/gen.py`; extend `tools/test_gen.py`; run `python3 tools/gen.py` and commit the generated `themes/<app>/`.
2. **dotfiles:** add one row to `script/theme-manifest`:
   `name | wana_src{v} | repo_dest{v} | home_current | home_variant{v} | reload | mode`
   Leave `mode` blank for a whole-file target (Class A/B). Use `mode=patch` for a
   Class C target — one whose `repo_dest` is a hand-authored file that only
   embeds a generated fragment; wrap that fragment in pre-existing
   `# wana:begin` / `# wana:end` markers (added once, by hand) and `theme-sync`
   will replace only what's between them.
3. Run `./script/theme-sync` to vendor the files; commit them.
4. Add the app's `include`/`import` of its `*current*` symlink; gitignore the runtime symlink.
5. `theme-switch dark` to materialize symlinks; verify.

Switch variants any time with `theme-switch {dark|light|toggle}`. `theme-sync --check`
guards against drift between wana output and the vendored copies (Class C included).

**App-theming ownership:** the wana pipeline owns portable CLI/TUI apps (terminals, bat, fzf, btop, lazygit, opencode, starship, tmux, herdr, yazi, …). Noctalia's templating owns desktop-only GUI apps (gtk/qt/compositor/zathura/telegram/cava). Keep them disjoint — if you add a wana target for an app Noctalia also templates, disable that template in `~/.local/state/noctalia/settings.toml` `[theme.templates]`.

**Multiplexers:** `app/tmux` is the primary multiplexer (TTY/SSH/server, plugin-free); herdr is the desktop-GUI multiplexer. Both are wana theme targets — tmux as a Class A symlink, herdr as a Class C in-place block (`mode=patch`).

---

## Secrets

Read `docs/secrets.md` before changing SOPS/age integration. Retain encrypted
sources and local key ownership. Deploy only the manifest's explicit sources;
keep decrypted values, local overrides and caches outside the Nix snapshot.

The old setup.sh/bootstrap.sh deployment has been retired. Historical docs
mentioning it do not describe the supported deployment command.
