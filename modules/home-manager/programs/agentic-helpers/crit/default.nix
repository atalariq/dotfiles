{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
{
  options.dotfiles.programs.crit.enable = lib.mkEnableOption "crit";
  config = lib.mkIf config.dotfiles.programs.crit.enable {
    home.packages = [ inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.crit ];

    home.sessionVariables.CRIT_NO_UPDATE_CHECK = "1";

    # Authentication and review state remain writable; seed only when absent.
    xdg.configFile."dotfiles/templates/crit.json".text = builtins.toJSON {
      share_targets = [ ];
    };
  };
}
