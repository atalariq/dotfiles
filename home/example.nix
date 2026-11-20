# The terminal profile every example uses. Override any option in your own
# flake or host module.
{ ... }:
{
  imports = [ ../modules/home-manager ];

  dotfiles.programs.cli = {
    enable = true;
    neovim = {
      enable = true;
      profile = "minimal";
    };
    helix.enable = true;
    yazi.enable = true;
    atuin.enable = true;
    btop.enable = true;
    fastfetch.enable = true;
    gh.enable = true;
    tmux.enable = true;
    typst.enable = true;
    yt-dlp.enable = true;
  };

  dotfiles.programs.development = {
    direnv.enable = true;
    mise.enable = true;
  };

  # Stylix gives kitty/nvim/starship one palette. GUI targets stay off by
  # default so the same profile works on a headless or borrowed machine.
  dotfiles.appearance = {
    enable = true;
    gui = false;
    theme = "gruvbox-dark";
  };
}
