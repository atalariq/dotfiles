# Agent profile seeding, not a bundle.
#
# Enabling agent tools is each host's choice, made per tool through
# `dotfiles.programs.agentic.<name>.enable` (and the shared
# `agentic.core.enable` floor). This module performs the one operation no
# client module can do declaratively: copy ABSENT native profiles from the
# managed templates at activation, without ever touching existing state.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  programs = config.dotfiles.programs.agentic;
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
      enable = programs.agy.enable && programs.core.enable;
      template = "agy-mcp.json";
      target = "${config.home.homeDirectory}/.gemini/config/mcp_config.json";
    }
    {
      enable = programs.claude.enable && programs.core.enable;
      template = "claude-mcp.json";
      target = "${config.home.homeDirectory}/.claude.json";
    }
  ];
in
{
  # Home Manager's native activation DAG is sufficient; no startup wrapper,
  # profile reconciler, credential loader, or background service is needed.
  config.home.activation.seedAgentProfiles = lib.hm.dag.entryAfter [ "linkGeneration" ] (
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
