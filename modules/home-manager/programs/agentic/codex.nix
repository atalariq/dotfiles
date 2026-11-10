{
  config,
  inputs,
  pkgs,
  lib,
  ...
}:
let
  toml = pkgs.formats.toml { };
  python = pkgs.python3.withPackages (ps: [ ps.tomlkit ]);
  mergeScript = pkgs.writeText "codex-keymap-merge.py" ''
    import sys
    import tomlkit

    path = sys.argv[1]
    with open(path, encoding="utf-8") as handle:
        document = tomlkit.parse(handle.read())

    def table(parent, key):
        value = parent.get(key)
        if not isinstance(value, dict):
            value = tomlkit.table()
            parent[key] = value
        return value

    tui = table(document, "tui")
    if "vim_mode_default" not in tui:
        tui["vim_mode_default"] = True

    keymap = table(tui, "keymap")
    global_keys = table(keymap, "global")
    if "open_external_editor" not in global_keys:
        global_keys["open_external_editor"] = "ctrl-g"

    composer = table(keymap, "composer")
    if "insert_newline" not in composer:
        composer["insert_newline"] = ["shift-enter", "ctrl-j"]

    with open(path, "w", encoding="utf-8") as handle:
        handle.write(tomlkit.dumps(document))
  '';
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

    # Codex owns config.toml. Add only the common keymap/vim defaults to an
    # existing profile; comments and user overrides are preserved.
    home.activation.mergeCodexKeymap = lib.hm.dag.entryAfter [ "seedAgentProfiles" ] ''
      target=${lib.escapeShellArg "${config.home.homeDirectory}/.codex/config.toml"}
      if [[ -f "$target" ]]; then
        backup="$target.dotfiles-backup"
        if [[ ! -e "$backup" ]]; then
          run ${pkgs.coreutils}/bin/cp -- "$target" "$backup"
        fi
        run ${python}/bin/python ${mergeScript} "$target"
      fi
    '';
  };
}
