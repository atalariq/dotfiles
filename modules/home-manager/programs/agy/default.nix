{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  options.dotfiles.programs.agy.enable = lib.mkEnableOption "Google Antigravity CLI";

  config = lib.mkIf config.dotfiles.programs.agy.enable {
    home.packages = [ inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.antigravity-cli ];

    # agy normalizes settings.json on startup and stores permission decisions there.
    # Supply a seed separately; account state and the working profile remain writable.
    xdg.configFile."dotfiles/templates/agy.json".text = builtins.toJSON {
      "$schema" = "https://antigravity.google/schemas/v1/settings.json";
      agentMode = "auto";
      enableTerminalSandbox = true;
      toolPermission = "proceed-in-sandbox";
      allowNonWorkspaceAccess = false;
      artifactReviewPolicy = "always-proceed";
      useG1Credits = false;
      permissions = {
        allow = [
          "read_url(antigravity.google)"
          "read_url(developers.google.com)"
          "read_url(docs.github.com)"
          "read_url(nixos.org)"
        ];
        ask = [
          "command(sudo)"
          "command(doas)"
          "command(pkexec)"
          "command(git add)"
          "command(git commit)"
          "command(git push)"
          "command(gh pr create)"
          "command(gh release)"
          "command(nixos-rebuild)"
          "command(darwin-rebuild)"
          "command(home-manager switch)"
          "command(just apply-)"
          "command(nix run)"
        ];
        deny = [
          "command(git reset)"
          "command(git clean)"
          "command(rm -rf)"
        ]
        ++ map (path: "read_file(${path})") [
          "${config.home.homeDirectory}/.ssh"
          "${config.home.homeDirectory}/.gnupg"
          "${config.xdg.configHome}/age"
          "${config.xdg.configHome}/sops"
          "${config.xdg.configHome}/sops-nix/secrets"
        ];
      };
    };
    # Merge only this named entry into the writable native MCP map. agy owns
    # unrelated servers and any authentication associated with them.
    xdg.configFile."dotfiles/templates/agy-mcp.json" =
      lib.mkIf config.dotfiles.programs.codegraph.enable
        {
          text = builtins.toJSON {
            mcpServers.codegraph = {
              command = "codegraph";
              args = [
                "serve"
                "--mcp"
              ];
            };
          };
        };
  };
}
