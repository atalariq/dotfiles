{
  config,
  lib,
  pkgs,
  inputs,
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
  options.dotfiles.programs.copilot.enable = lib.mkEnableOption "GitHub Copilot CLI";

  config = lib.mkIf config.dotfiles.programs.copilot.enable {
    home.packages = [
      inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.copilot-cli
    ]
    ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
      pkgs.bubblewrap
      pkgs.slirp4netns
      pkgs.util-linux
      pkgs.iptables-nftables-compat
    ];

    # config.json and permissions-config.json belong to Copilot. Seed settings.json
    # manually so /settings can save preferences without modifying the Nix store.
    xdg.configFile."dotfiles/templates/copilot.json".text = builtins.toJSON (
      lib.recursiveUpdate (builtins.fromJSON (builtins.readFile ./settings.json)) {
        sandbox.userPolicy.filesystem = {
          readwritePaths = [
            rtkData
            "${config.xdg.cacheHome}/nix"
          ]
          ++ lib.optional config.dotfiles.programs.beads-rust.enable config.dotfiles.programs.beads-rust.directory;
          readonlyPaths = lib.optionals pkgs.stdenv.hostPlatform.isLinux [ "${config.xdg.configHome}/rtk" ];
          deniedPaths = [
            "${config.home.homeDirectory}/.ssh"
            "${config.home.homeDirectory}/.gnupg"
            "${config.xdg.configHome}/age"
            "${config.xdg.configHome}/sops"
            "${config.xdg.configHome}/sops-nix/secrets"
          ];
        };
      }
    );
    # Native MCP state remains writable; provisioning creates this seed only when absent.
    xdg.configFile."dotfiles/templates/copilot-mcp.json" =
      lib.mkIf config.dotfiles.programs.codegraph.enable
        {
          text = builtins.toJSON {
            mcpServers.codegraph = {
              type = "local";
              command = "codegraph";
              args = [
                "serve"
                "--mcp"
              ];
              tools = [ "*" ];
            };
          };
        };

  };
}
