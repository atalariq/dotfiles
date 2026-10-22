{
  config,
  pkgs,
  checkout,
  ...
}:
{

  # Lua and vim.pack own the editor configuration and plugins.
  xdg.configFile.nvim.source = config.lib.file.mkOutOfStoreSymlink "${checkout}/home/neovim/config";
  xdg.configFile."vale/.vale.ini".source =
    config.lib.file.mkOutOfStoreSymlink "${checkout}/home/neovim/vale.ini";
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    GIT_EDITOR = "nvim";
  };

  home.packages = with pkgs; [
    neovim
    # :PackInstall and :TSInstallBaseline are explicit bootstrap steps.
    gzip
    gcc
    tree-sitter
    nixd
    nixfmt
    lua-language-server
    stylua
    bash-language-server
    shellcheck
    shfmt
    marksman
    rumdl
    yaml-language-server
    yamlfmt
    yamllint
    tombi
  ];
}
