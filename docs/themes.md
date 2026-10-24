# Appearance

`dotfiles.desktop.appearance.enable` enables Stylix and explicit appearance
adapters. `dotfiles.desktop.appearance.theme` defaults to `gruvbox-dark`
(Gruvbox Dark Medium); `gruvbox-light` is the second prebuilt choice.

```sh
dotfiles-theme list
dotfiles-theme current
dotfiles-theme set gruvbox-light
dotfiles-theme set gruvbox-dark
```

These commands activate prebuilt Home Manager specialisations. They do not build
packages or require sudo. They require an initial base Home Manager activation.
The base generation catalogue is registered as an indirect Nix GC root and kept separately from the active variant, so
switching repeatedly never loses the list of available themes. The last valid
selection survives a base deployment; a removed/invalid selection falls back to
the declared default. Activation is a Home Manager operation and retains its
normal collision checks.

Stylix owns GTK/Qt, selected application themes and fonts. Small adapters provide
Noctalia's palette, Mango borders, native Kitty/tmux/Fish/fzf configuration,
Herdr and the shared editor's palette data. Noctalia's template generation is
turned off. Native palette assets such as rmpc use the selected Stylix roles.
Theme assets are generated even in live source mode; native behaviour files
still follow the checkout where their module uses live sources.

Kitty, tmux and Noctalia receive reload requests. Existing Fish shells, editors
and applications without hot reload may need reopening. The shared nvf binary
reads an optional palette file from `dotfiles-theme/neovim.lua`; without Home
Manager it uses its embedded Gruvbox fallback. Vim's generated colours are an
ordinary Vimscript file, not a plugin dependency. A copied vimrc still works
independently.

Inter is the sans-serif default, Fira Code the monospace default, and Nerd Font
Symbols Only supplies symbols without replacing the text fonts. DejaVu Serif
remains the serif fallback. Times New Roman and EB Garamond are installed for
specific documents; Typst defaults separately to New Computer Modern.
Icons are Papirus-Dark; the cursor is Bibata Modern Ice at size 24.

Add a future handmade Base16 scheme to `themes/default.nix`; the active Wana
assets and old generated plugin lock have been removed. Defining a new scheme
requires rebuilding its variants once before runtime selection becomes available.

The optional real activation test is `python3 tests/activation.py`. It uses a
temporary HOME, Nix profile and D-Bus session; it checks real specialisation
activation and GC-root reachability without collecting store paths.
