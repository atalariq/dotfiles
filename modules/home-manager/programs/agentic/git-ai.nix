{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
{
  options.dotfiles.programs.agentic.git-ai = {
    enable = lib.mkEnableOption "git-ai";
    repositories = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Remote repository URLs allowed to record local AI attribution.";
    };
  };
  config = lib.mkIf config.dotfiles.programs.agentic.git-ai.enable {
    assertions = [
      {
        assertion = config.dotfiles.programs.agentic.git-ai.repositories != [ ];
        message = "git-ai requires an explicit repositories allowlist; its native empty list permits every repository.";
      }
    ];
    home.packages = [ inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.git-ai ];

    # The real user config may also contain authentication. Keep it writable.
    xdg.configFile."dotfiles/templates/git-ai.json".text = builtins.toJSON {
      git_path = "${pkgs.git}/bin/git";
      allow_repositories = config.dotfiles.programs.agentic.git-ai.repositories;
      prompt_storage = "local";
      telemetry_oss = "off";
      feature_flags = {
        daemon_log_upload = false;
        transcript_streaming = false;
        transcript_sweep = false;
        token_usage_metrics = false;
      };
      disable_auto_updates = true;
      disable_version_checks = true;
    };
  };
}
