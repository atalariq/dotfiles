{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  options.dotfiles.programs.hermes.enable = lib.mkEnableOption "Hermes CLI through the local gateway";
  config = lib.mkIf config.dotfiles.programs.hermes.enable {
    home.packages = [ inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.hermes-agent ];
    # Nix owns settings; upstream memories, sessions and OAuth files stay writable.
    home.file.".hermes/config.yaml".source = ./config/config.yaml;
  };
}
