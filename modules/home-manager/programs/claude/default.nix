{
  config,
  inputs,
  pkgs,
  lib,
  ...
}:
let
  rtkData =
    if pkgs.stdenv.hostPlatform.isDarwin then
      "${config.home.homeDirectory}/Library/Application Support/rtk"
    else
      "${config.xdg.dataHome}/rtk";
in
{

  options.dotfiles.programs.claude.enable = lib.mkEnableOption "claude configuration";

  config = lib.mkIf config.dotfiles.programs.claude.enable {

    # llm-agents supplies bubblewrap/socat through the Claude wrapper.
    home.packages = [ inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.claude-code ];
    xdg.configFile."dotfiles/templates/claude.json".text = builtins.toJSON (
      lib.recursiveUpdate (builtins.fromJSON (builtins.readFile ./template.json)) {
        sandbox.filesystem = {
          allowRead = [
            rtkData
          ]
          ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [ "${config.xdg.configHome}/rtk" ];
          allowWrite = [
            rtkData
            "${config.xdg.cacheHome}/nix"
          ];
        };
      }
    );

  };
}
