{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.dotfiles.services.secrets;
in
{
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];
  options.dotfiles.services = {
    secrets = {
      enable = lib.mkEnableOption "per-application runtime secrets";
      file = lib.mkOption {
        type = lib.types.path;
        default = ../../../secrets/secrets.yaml;
        description = "Encrypted SOPS source. Plaintext must never enter the store.";
      };
      keyFile = lib.mkOption {
        type = lib.types.str;
        default = "${config.xdg.configHome}/sops/age/keys.txt";
        description = "Existing private age identity, provisioned outside Git.";
      };
      applications = lib.mkOption {
        type = lib.types.attrsOf (lib.types.attrsOf lib.types.str);
        default = { };
        example = {
          hermes.DEEPSEEK_API_KEY = "DEEPSEEK_API_KEY_HERMES";
        };
        description = "Application names mapped to environment names and SOPS keys.";
      };
    };
  };
  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      sops = {
        defaultSopsFile = cfg.file;
        age.keyFile = cfg.keyFile;
        secrets = lib.genAttrs (lib.unique (
          lib.concatMap builtins.attrValues (builtins.attrValues cfg.applications)
        )) (_: { });
      };
      # The wrapper reads runtime files only. It neither prints secret values
      # nor exports unrelated credentials into the parent shell.
      home.packages = lib.mapAttrsToList (
        name: environment:
        pkgs.writeShellScriptBin "${name}-with-secrets" ''
          set -eu
          ${lib.concatStringsSep "\n" (
            lib.mapAttrsToList (variable: key: ''
              test -r ${lib.escapeShellArg config.sops.secrets.${key}.path} || {
                echo "Secret unavailable: start sops-nix.service and provision its age key." >&2
                exit 1
              }
              ${variable}="$(${pkgs.coreutils}/bin/cat ${lib.escapeShellArg config.sops.secrets.${key}.path})"
              export ${variable}
            '') environment
          )}
          if [ "$#" -eq 0 ]; then
            echo "Usage: ${name}-with-secrets command [arguments...]" >&2
            exit 2
          fi
          exec "$@"
        ''
      ) cfg.applications;
      assertions = [
        {
          assertion = lib.all (
            environment:
            lib.all (name: builtins.match "[A-Za-z_][A-Za-z0-9_]*" name != null) (
              builtins.attrNames environment
            )
          ) (builtins.attrValues cfg.applications);
          message = "Secret environment names must be valid shell identifiers.";
        }
      ];
    })
  ];
}
