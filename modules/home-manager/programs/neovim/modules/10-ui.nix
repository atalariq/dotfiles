# Lua: config/lua/colorscheme.lua (applies the palette through mini.base16),
#      config/lua/theme/palette.lua (portable gruvbox fallback),
#      config/lua/plugins/mini.lua (statusline, tabline, icons, hipatterns, clue),
#      config/init.lua (`vim.g.have_nerd_font` switches icon usage).
#
# Stylix owns the generated theme file (`~/.config/dotfiles-theme/neovim.lua`,
# read at runtime); `theme/palette.lua` is the safe fallback. No colour value is
# duplicated here — nvf only supplies the mini.* plugins (20-plugins.nix) and the
# clipboard helper that image paste needs (`img-clip`).
{ pkgs, lib, ... }:
{
  vim = {
    extraPackages = lib.optionals pkgs.stdenv.hostPlatform.isLinux [
      # wl-copy/wl-paste back the clipboard provider behind <leader>p (img-clip).
      pkgs.wl-clipboard
    ];
  };
}
