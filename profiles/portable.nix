{ ... }:
{
  imports = [ ../modules/home-manager ];
  home.username = "atalariq";
  home.homeDirectory = "/home/atalariq";
  home.stateVersion = "26.05";
  xdg.enable = true;
  programs.home-manager.enable = true;
  # Portable means a Linux CLI/editor environment, not a desktop profile.
  dotfiles = {
    terminal.bash.enable = true;
    terminal.direnv.enable = true;
    terminal.fish.enable = true;
    terminal.atuin.enable = true;
    terminal.zoxide.enable = true;
    terminal.starship.enable = true;
    terminal.core.enable = true;
    terminal.bat.enable = true;
    terminal.fd.enable = true;
    terminal.ripgrep.enable = true;
    terminal.fzf.enable = true;
    terminal.yazi.enable = true;

    development.git.enable = true;
    development.gh.enable = true;
    development.lazygit.enable = true;
    terminal.tmux.enable = true;
    editors.neovim.enable = true;
    editors.vim.enable = true;
    development.tools.enable = true;
    academic.typst.enable = true;
    agents.rtk.enable = true;
    agents.tirith.enable = true;
    agents.opencode.enable = true;
    agents.codex.enable = true;
    agents.claude.enable = true;
  };
}
