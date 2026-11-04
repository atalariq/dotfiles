{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
{
  options.dotfiles.programs.agentic.agent-browser.enable = lib.mkEnableOption "agent-browser";
  config = lib.mkIf config.dotfiles.programs.agentic.agent-browser.enable {
    home.packages = [ inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.agent-browser ];

    # The upstream wrapper pins AGENT_BROWSER_EXECUTABLE_PATH to its bundled
    # Chromium. On the Linux desktop, prefer the user's Brave Origin so
    # Chrome-only agent integrations keep the same browser/profile. The CLI
    # flag takes precedence over the wrapper environment.
    home.file.".local/bin/agent-browser" =
      lib.mkIf (pkgs.stdenv.hostPlatform.isLinux && config.dotfiles.programs.gui.brave-origin.enable)
        {
          source = pkgs.writeShellScript "agent-browser-brave" ''
            exec ${
              inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.agent-browser
            }/bin/agent-browser \
              --executable-path ${config.dotfiles.programs.gui.brave-origin.package}/bin/brave-origin "$@"
          '';
        };
  };
}
