{
  config,
  inputs,
  pkgs,
  lib,
  ...
}:
let
  format = pkgs.formats.json { };
  native = builtins.fromJSON (builtins.readFile ./config/opencode/opencode.jsonc);
  seed = lib.recursiveUpdate (builtins.fromJSON (builtins.readFile ./config/opencode/providers.json)) native;
  # llm-agents packages the v2 CLI as `opencode2`, but every recipe, hook and
  # skill in this repository calls `opencode`; expose exactly one name.
  package =
    let
      v2 = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.opencode2;
    in
    pkgs.symlinkJoin {
      name = "opencode";
      paths = [ v2 ];
      postBuild = "mv $out/bin/opencode2 $out/bin/opencode";
    };
in
{

  options.dotfiles.programs.agentic.opencode.enable = lib.mkEnableOption "opencode configuration";

  config = lib.mkIf config.dotfiles.programs.agentic.opencode.enable {

    home.packages = [ package ];
    # Native CLI/MCP commands rewrite this file, so keep the working profile
    # writable and seed a minimal default (direct DeepSeek + opt-out of sharing).
    xdg.configFile."dotfiles/templates/opencode-cli.json".source = ./config/opencode/cli.json;
    xdg.configFile."dotfiles/templates/opencode.jsonc".source = format.generate "opencode.json" (
      lib.recursiveUpdate seed {
        mcp.servers =
          lib.optionalAttrs config.dotfiles.programs.agentic.core.enable {
            codegraph = {
              type = "local";
              command = [
                "codegraph"
                "serve"
                "--mcp"
              ];
            };
          }
          // lib.optionalAttrs config.dotfiles.programs.agentic.agent-browser.enable {
            agent-browser = {
              type = "local";
              command = [
                "agent-browser"
                "mcp"
              ];
            };
          };
      }
    );

    # OpenCode owns cli.json, so only add the shared keybinds/plugin when they
    # are absent. Existing user values win.
    home.activation.mergeOpencodeCli = lib.hm.dag.entryAfter [ "seedAgentProfiles" ] ''
      target=${lib.escapeShellArg "${config.xdg.configHome}/opencode/cli.json"}
      defaults=${
        lib.escapeShellArg (toString config.xdg.configFile."dotfiles/templates/opencode-cli.json".source)
      }
      if [[ -f "$target" ]]; then
        backup="$target.dotfiles-backup"
        if [[ ! -e "$backup" ]]; then
          run ${pkgs.coreutils}/bin/cp -- "$target" "$backup"
        fi
        tmp=$(run ${pkgs.coreutils}/bin/mktemp "$target.XXXXXX")
        run ${pkgs.jq}/bin/jq --slurpfile d "$defaults" '
          .keybinds = ($d[0].keybinds * (.keybinds // {}))
          | .plugins =
              ((.plugins // []) as $p
               | if any($p[];
                    (type == "object" and .package == $d[0].plugins[0].package)
                    or . == $d[0].plugins[0].package)
                 then $p
                 else $p + [$d[0].plugins[0]]
                 end)
        ' "$target" > "$tmp"
        run ${pkgs.coreutils}/bin/chmod 600 "$tmp"
        run ${pkgs.coreutils}/bin/mv -- "$tmp" "$target"
      fi
    '';
  };
}
