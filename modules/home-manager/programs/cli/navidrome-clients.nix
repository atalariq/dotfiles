# Experimental Navidrome clients. Both are opt-in and deliberately limited to
# hosts where interactive audio works; the headless server stays client-free.
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.dotfiles.programs.cli.navidrome-clients;
  system = pkgs.stdenv.hostPlatform.system;
in
{
  imports = [ inputs.ratune.homeManagerModules.default ];

  options.dotfiles.programs.cli.navidrome-clients = {
    enable = lib.mkEnableOption "the Navidrome client experiment";
    serverUrl = lib.mkOption {
      type = lib.types.str;
      default = "http://homelab-x456urk:4533";
      description = "Navidrome URL used for first-run setup.";
    };
    ratune.enable = lib.mkEnableOption "Ratune TUI";
    navibeat.enable = lib.mkEnableOption "NaviBeat (TUI mode)";
  };

  config = lib.mkIf (config.dotfiles.programs.cli.enable && cfg.enable) {
    programs.ratune.enable = cfg.ratune.enable;

    home.packages = lib.optional (
      cfg.navibeat.enable && system == "x86_64-linux"
    ) inputs.navibeat.packages.${system}.default;
  };
}
