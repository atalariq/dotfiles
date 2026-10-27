{
  config,
  lib,
  pkgs,
  ...
}:
let
  programs = config.dotfiles.programs;
  # Native profiles are writable. Seed only absent files; rebuilding must never
  # reset account state, models, permission decisions, or application preferences.
  profiles = lib.filter (profile: profile.enable) [
    {
      enable = programs.codex.enable;
      template = "codex.toml";
      target = "${config.home.homeDirectory}/.codex/config.toml";
    }
    {
      enable = programs.claude.enable;
      template = "claude.json";
      target = "${config.home.homeDirectory}/.claude/settings.json";
    }
    {
      enable = programs.agy.enable;
      template = "agy.json";
      target = "${config.home.homeDirectory}/.gemini/antigravity-cli/settings.json";
    }
    {
      enable = programs.copilot.enable;
      template = "copilot.json";
      target = "${config.home.homeDirectory}/.copilot/settings.json";
    }
    {
      enable = programs.opencode.enable;
      template = "opencode.jsonc";
      target = "${config.xdg.configHome}/opencode/opencode.jsonc";
    }
    {
      enable = programs.hermes.enable;
      template = "hermes.yaml";
      target = "${config.home.homeDirectory}/.hermes/config.yaml";
    }
    {
      enable = programs.agy.enable && programs.codegraph.enable;
      template = "agy-mcp.json";
      target = "${config.home.homeDirectory}/.gemini/config/mcp_config.json";
    }
    {
      enable = programs.copilot.enable && programs.codegraph.enable;
      template = "copilot-mcp.json";
      target = "${config.home.homeDirectory}/.copilot/mcp-config.json";
    }
    {
      enable = programs.claude.enable && programs.codegraph.enable;
      template = "claude-mcp.json";
      target = "${config.home.homeDirectory}/.claude.json";
    }
  ];
in
{
  options.dotfiles.ai.enable = lib.mkEnableOption "the coding-agent bundle with native client integration";

  config = lib.mkMerge [
    (lib.mkIf config.dotfiles.ai.enable {
      dotfiles.programs = {
        codex.enable = lib.mkDefault true;
        claude.enable = lib.mkDefault true;
        opencode.enable = lib.mkDefault true;
        hermes.enable = lib.mkDefault true;
        beads-rust.enable = lib.mkDefault true;
        codegraph.enable = lib.mkDefault true;
        rtk.enable = lib.mkDefault true;
        tokscale.enable = lib.mkDefault true;
      };
    })
    {
      # Home Manager's native activation DAG is sufficient; no startup wrapper,
      # profile reconciler, credential loader, or background service is needed.
      home.activation.seedAgentProfiles = lib.hm.dag.entryAfter [ "linkGeneration" ] (
        lib.concatMapStringsSep "\n" (
          profile:
          let
            target = lib.escapeShellArg profile.target;
            parent = lib.escapeShellArg (builtins.dirOf profile.target);
            source = lib.escapeShellArg (
              toString config.xdg.configFile."dotfiles/templates/${profile.template}".source
            );
          in
          ''
            if [[ ! -e ${target} && ! -L ${target} ]]; then
              run mkdir -p ${parent}
              (
                umask 077
                seed_tmp=$(run ${pkgs.coreutils}/bin/mktemp ${parent}/.dotfiles-seed.XXXXXX)
                trap 'run rm -f -- "$seed_tmp"' EXIT
                run ${pkgs.coreutils}/bin/cp --no-preserve=mode ${source} "$seed_tmp"
                # Publish a complete copy atomically. A concurrent activation
                # may already have created the destination; never replace it.
                run ${pkgs.coreutils}/bin/ln -T -- "$seed_tmp" ${target} || [[ -e ${target} || -L ${target} ]]
              )
            fi
          ''
        ) profiles
      );
    }
  ];
}
