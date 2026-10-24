{ ... }:
{
  # Language runtimes belong to project devShells; the editor owns its LSP tools.
  programs.git.enable = true;
  programs.delta.enable = true;
  programs.delta.enableGitIntegration = true;
  programs.jujutsu.enable = true;
  programs.television = {
    enable = true;
  };
  dotfiles.programs = {
    gh.enable = true;
    lazygit.enable = true;
    neovim.enable = true;
    typst.enable = true;
    rtk.enable = true;
    tirith.enable = true;
    opencode.enable = true;
    codex.enable = true;
    claude.enable = true;
  };
}
