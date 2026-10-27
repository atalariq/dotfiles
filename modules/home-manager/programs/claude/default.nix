{
  config,
  inputs,
  pkgs,
  lib,
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

  options.dotfiles.programs.claude.enable = lib.mkEnableOption "claude configuration";

  config = lib.mkIf config.dotfiles.programs.claude.enable {

    # Local Git work remains sandboxed; AGENTS limits commit authority to assigned
    # worktrees. Native permissions are not a CWD-specific Git-index ACL.
    # llm-agents supplies bubblewrap/socat through the Claude wrapper.
    home.packages = [ inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.claude-code ];
    xdg.configFile."dotfiles/templates/claude.json".text = builtins.toJSON (
      lib.recursiveUpdate (builtins.fromJSON (builtins.readFile ./template.json)) {
        permissions.additionalDirectories = lib.optional config.dotfiles.programs.beads-rust.enable config.dotfiles.programs.beads-rust.directory;
        sandbox.filesystem = {
          allowRead = [
            rtkData
          ]
          ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [ "${config.xdg.configHome}/rtk" ]
          ++ lib.optional config.dotfiles.programs.beads-rust.enable config.dotfiles.programs.beads-rust.directory;
          allowWrite = [
            rtkData
            "${config.xdg.cacheHome}/nix"
          ]
          ++ lib.optional config.dotfiles.programs.beads-rust.enable config.dotfiles.programs.beads-rust.directory;
        };
      }
    );

    # Native MCP state remains writable; provisioning creates this seed only when absent.
    xdg.configFile."dotfiles/templates/claude-mcp.json" =
      lib.mkIf config.dotfiles.programs.codegraph.enable
        {
          text = builtins.toJSON {
            mcpServers.codegraph = {
              type = "stdio";
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
