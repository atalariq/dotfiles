{
  config,
  inputs,
  pkgs,
  lib,
  ...
}:
let
  toml = pkgs.formats.toml { };
  settings =
    lib.recursiveUpdate (builtins.fromTOML (builtins.readFile ./config/codex/template.toml))
      {
        mcp_servers =
          lib.optionalAttrs config.dotfiles.programs.agentic.core.enable {
            codegraph = {
              command = "codegraph";
              args = [
                "serve"
                "--mcp"
              ];
            };
          }
          // lib.optionalAttrs config.dotfiles.programs.agentic.agent-browser.enable {
            agent-browser = {
              command = "agent-browser";
              args = [ "mcp" ];
            };
          };
      };
in
{

  options.dotfiles.programs.agentic.codex.enable = lib.mkEnableOption "codex configuration";

  config = lib.mkIf config.dotfiles.programs.agentic.codex.enable {

    home.packages = [ inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.codex ];
    # Codex rewrites its base config natively. Seed only a shared default when the
    # target does not exist; approvals, sandboxing and account state stay local.
    xdg.configFile."dotfiles/templates/codex.toml".source = toml.generate "codex.toml" settings;

  };
}
