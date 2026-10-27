{
  config,
  lib,
  inputs,
  ...
}:
let
  cfg = config.dotfiles.services.secrets;
  secretFile =
    description:
    lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      inherit description;
    };
in
{
  imports = [ inputs.sops-nix.homeManagerModules.sops ];
  options.dotfiles.services.secrets = {
    enable = lib.mkEnableOption "application-scoped runtime SOPS files";
    keyFile = lib.mkOption {
      type = lib.types.str;
      default = "${config.xdg.configHome}/sops/age/keys.txt";
      description = "Private age identity provisioned outside the repository.";
    };
    files = {
      hermes = secretFile "Encrypted YAML with an environment scalar containing Hermes dotenv data.";
      opencode = secretFile "Encrypted YAML with a gateway_api_key scalar.";
      aiProviders = secretFile "Encrypted YAML with OpenRouter and DeepSeek provider API key scalars.";
      credentials = secretFile "Encrypted YAML with non-AI credentials (AUR, GitHub, Google Tasks) and the mpdscribble Last.fm configuration.";
    };
  };
  config = lib.mkIf cfg.enable {
    sops.age.keyFile = cfg.keyFile;
    # Whole env scalars preserve dotenv escaping; no secrets are interpolated in Nix.
    sops.secrets =
      lib.optionalAttrs (cfg.files.hermes != null) {
        hermes-env = {
          sopsFile = cfg.files.hermes;
          key = "environment";
          path = "${config.home.homeDirectory}/.hermes/.env";
          mode = "0600";
        };
      }
      // lib.optionalAttrs (cfg.files.opencode != null) {
        opencode-key = {
          sopsFile = cfg.files.opencode;
          key = "gateway_api_key";
          mode = "0600";
        };
      }
      // lib.optionalAttrs (cfg.files.aiProviders != null) {
        "openrouter-api-key" = {
          sopsFile = cfg.files.aiProviders;
          key = "openrouter_api_key";
          mode = "0600";
        };
        "deepseek-api-key" = {
          sopsFile = cfg.files.aiProviders;
          key = "deepseek_api_key";
          mode = "0600";
        };
      }
      // lib.optionalAttrs (cfg.files.credentials != null) {
        # Whole decrypted document for manual reference, plus the mpdscribble
        # document that its service conditions on. Nothing is interpolated in Nix.
        credentials = {
          sopsFile = cfg.files.credentials;
          key = "";
          path = "${config.xdg.configHome}/sops-nix/credentials.yaml";
          mode = "0600";
        };
        "mpdscribble-conf" = {
          sopsFile = cfg.files.credentials;
          key = "mpdscribble_conf";
          path = "${config.home.homeDirectory}/.config/mpdscribble/mpdscribble.conf";
          mode = "0600";
        };
      };
    assertions = [
      {
        assertion =
          cfg.files.hermes != null
          || cfg.files.opencode != null
          || cfg.files.aiProviders != null
          || cfg.files.credentials != null;
        message = "Enable secrets only after selecting actual encrypted per-application files.";
      }
    ];
  };
}
