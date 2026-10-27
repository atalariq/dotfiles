{
  config,
  inputs,
  pkgs,
  lib,
  ...
}:
let
  toml = pkgs.formats.toml { };
  settings = lib.recursiveUpdate (builtins.fromTOML (builtins.readFile ./template.toml)) {
    mcp_servers = lib.optionalAttrs config.dotfiles.programs.codegraph.enable {
      codegraph = {
        command = "codegraph";
        args = [
          "serve"
          "--mcp"
        ];
      };
    };
    shell_environment_policy.set = lib.optionalAttrs config.dotfiles.programs.beads-rust.enable {
      DOTFILES_BEADS_DIR = config.dotfiles.programs.beads-rust.directory;
    };
    # Keep credential directories hidden without blocking normal Nix caches,
    # project evidence, or other explicitly authorized project checkouts.
    permissions.development.filesystem = {
      "${config.home.homeDirectory}/.ssh" = "deny";
      "${config.home.homeDirectory}/.gnupg" = "deny";
      "${config.xdg.configHome}/age" = "deny";
      "${config.xdg.configHome}/sops" = "deny";
      # sops-nix/secrets is a runtime symlink; denying its real parent avoids
      # Bubblewrap trying to mount a deny over a symlink destination.
      "${config.xdg.configHome}/sops-nix" = "deny";
      "${config.xdg.configHome}/rtk" = "read";
      "${config.xdg.dataHome}/rtk" = "write";
      "${config.xdg.cacheHome}/nix" = "write";
    }
    // lib.optionalAttrs config.dotfiles.programs.beads-rust.enable {
      "${config.dotfiles.programs.beads-rust.directory}" = "write";
    }
    // lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
      "${config.home.homeDirectory}/Library/Application Support/rtk" = "write";
    };
  };
in
{

  options.dotfiles.programs.codex.enable = lib.mkEnableOption "codex configuration";

  config = lib.mkIf config.dotfiles.programs.codex.enable {

    home.packages = [ inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.codex ];
    # Codex >=0.163 loads this immutable layer without rewriting its base config.
    home.file.".codex/development.config.toml".source = toml.generate "codex-development.toml" settings;
    home.file.".codex/rules/dotfiles.rules".source = ./rules/dotfiles.rules;
    xdg.configFile."dotfiles/templates/codex.toml".source =
      toml.generate "codex-development.toml" settings;

    # Field-specific writable-base merge; never replace native account settings.
    xdg.configFile."dotfiles/templates/codex-ui.toml".source = toml.generate "codex-ui.toml" {
      tui = settings.tui;
    };

  };
}
