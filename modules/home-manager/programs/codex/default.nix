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
    # Workspace roots are more specific than this deny. Keep other home data
    # hidden; redundant nested denies break mount preparation in Codex 0.163.
    permissions.development.filesystem = {
      "${config.home.homeDirectory}" = "deny";
      "/run/user" = "deny";
      "${config.xdg.configHome}/rtk" = "read";
      "${config.xdg.dataHome}/rtk" = "write";
      "${config.xdg.cacheHome}/nix" = "write";
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
    xdg.configFile."dotfiles/templates/codex.toml".source =
      toml.generate "codex-development.toml" settings;

  };
}
