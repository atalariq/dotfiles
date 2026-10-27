{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.dotfiles.bundles.core.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "the core package bundle: standard POSIX tools, modern replacements and base ops";
  };

  # Standard POSIX/system tools plus their modern replacements (eza=ls, fd=find,
  # ripgrep=grep, bat=cat, trash-cli=rm, fzf, zoxide) and the base ops tools.
  # This is the "sunnah muakkad" set: enabled by default on every host.
  config = lib.mkIf config.dotfiles.bundles.core.enable {
    programs.fd = {
      enable = true;
      ignores = [
        ".git/"
        "node_modules/"
        "dist/"
        "build/"
        "target/"
        "coverage/"
        ".next/"
        ".expo/"
        ".gradle/"
        ".idea/"
        ".vscode/"
      ];
    };

    programs.ripgrep = {
      enable = true;
      arguments = [
        "--hidden"
        "--glob=!.git/*"
        "--glob=!node_modules/*"
        "--glob=!dist/*"
        "--glob=!build/*"
        "--glob=!target/*"
        "--glob=!coverage/*"
        "--smart-case"
        "--line-number"
        "--column"
      ];
    };

    programs.fzf = {
      enable = true;
      enableFishIntegration = false; # Television owns Ctrl-T, Atuin owns Ctrl-R.
      enableBashIntegration = false;
      enableZshIntegration = false;
      defaultOptions = [
        "--height=40%"
        "--layout=reverse"
        "--border"
      ];
      defaultCommand = "fd --type f --hidden --follow --exclude .git";
    };

    programs.bat.enable = true;
    programs.zoxide.enable = true;

    home.packages =
      with pkgs;
      [
        coreutils
        findutils
        gnugrep
        gnused
        diffutils
        wget
        gnutar
        unzip
        zip
        less
        eza
        trash-cli
        just
        jq
        curl
        rsync
      ]
      ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
        psmisc
        xdg-utils
        libsecret
        adwaita-icon-theme
      ];
  };
}
