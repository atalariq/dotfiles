{
  config,
  pkgs,
  lib,
  dotfilesLib,
  ...
}:
{

  options.dotfiles.agents.tirith.enable = lib.mkEnableOption "tirith configuration";

  config = lib.mkIf config.dotfiles.agents.tirith.enable {

    home.packages = with pkgs; [ tirith ];
    home.file.".tirith/policy.yaml".source = dotfilesLib.source ./config/tirith/policy.yaml;
    xdg.configFile."tirith/gateway.yaml".source = dotfilesLib.source ./config/gateway.yaml;

  };
}
