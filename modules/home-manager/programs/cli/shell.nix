{
  config,
  lib,
  ...
}:
let
  cli = config.dotfiles.programs.cli;
  cfg = cli.shell;
  source = import ../../lib/source.nix { inherit config; };
  baseline = import ../../../stylix/source-palette.nix;
  colours =
    if config.dotfiles.appearance.enable then
      config.lib.stylix.colors.withHashtag
    else
      lib.mapAttrs (_: value: "#${value}") baseline;
  # Keep the established prompt's role names while using Stylix's Base16 palette.
  roles = {
    blue = "base0D";
    red = "base08";
    green = "base0B";
    yellow = "base0A";
    cyan = "base0C";
    magenta = "base0E";
    white = "base05";
    black = "base00";
    text = "base05";
    subtext1 = "base04";
    subtext0 = "base04";
    overlay2 = "base03";
    overlay1 = "base03";
    overlay0 = "base03";
    surface2 = "base02";
    surface1 = "base01";
    surface0 = "base01";
    base = "base00";
    mantle = "base00";
    crust = "base00";
    rosewater = "base06";
    flamingo = "base08";
    pink = "base0E";
    mauve = "base0E";
    maroon = "base08";
    peach = "base09";
    teal = "base0C";
    sky = "base0C";
    sapphire = "base0D";
    lavender = "base07";
  };
in
{
  options.dotfiles.programs.cli.shell = {
    enable = lib.mkEnableOption "the shared fish/bash/starship shell layer" // {
      default = true;
    };
    fish.enable = lib.mkEnableOption "fish as the interactive shell" // {
      default = true;
    };
    bash.enable = lib.mkEnableOption "bash for POSIX scripting and fallback" // {
      default = true;
    };
    starship.enable = lib.mkEnableOption "the starship prompt" // {
      default = true;
    };
    zsh.enable = lib.mkEnableOption "zsh (the macOS default shell)";
  };

  config = lib.mkIf (cli.enable && cfg.enable) {
    # fish is the interactive shell; bash covers POSIX scripting and fallback
    # interactive use everywhere. zsh is the macOS default and stays opt-in.
    programs.fish.enable = lib.mkDefault cfg.fish.enable;
    programs.bash.enable = lib.mkDefault cfg.bash.enable;
    programs.starship.enable = lib.mkDefault cfg.starship.enable;
    programs.zsh.enable = lib.mkDefault cfg.zsh.enable;

    home.sessionPath = [ "${config.home.homeDirectory}/.local/bin" ];

    # The login shell stays the platform default (bash on Linux, zsh on macOS)
    # so scripts, `ssh host command` and cron keep the shell they expect. Only
    # an interactive session hands over to fish, and `$FISH_VERSION` keeps a
    # bash started *inside* fish from re-exec'ing into the same fish.
    # Home Manager appends `initExtra` after its own interactive guard.
    programs.bash.initExtra = lib.mkIf config.programs.fish.enable ''
      case $- in *i*) [ -z "$FISH_VERSION" ] && exec fish ;; esac
    '';
    # zsh follows the effective `programs.zsh.enable`, not the opt-in dotfiles
    # switch: macOS turns the native module on without selecting our wrapper,
    # and it still has to land in fish.
    programs.zsh.initContent = lib.mkIf (config.programs.zsh.enable && config.programs.fish.enable) ''
      if [[ -o interactive ]] && [[ -z "$FISH_VERSION" ]]; then
        exec fish
      fi
    '';

    programs.fish.generateCompletions = lib.mkIf config.programs.fish.enable true;
    # These render into ~/.config/fish/config.fish, which fish sources after
    # /etc/fish/config.fish, so they beat NixOS's system `alias ls 'ls --color=tty'`.
    programs.fish.shellAliases = lib.mkIf config.programs.fish.enable {
      ls = "eza --icons --group-directories-first";
      lla = "eza --icons --group-directories-first -algh";
      ll = "eza --icons --group-directories-first -lgh";
      lsa = "eza --icons --group-directories-first -a";
      lt = "eza --icons --group-directories-first -T";
      tree = "eza --icons --group-directories-first -T";
    };
    # conf.d also contains generated integrations and owner/private snippets, so
    # it is a mixed-ownership directory. Link only our snippets; history and
    # universal variables remain in their writable native locations.
    xdg.configFile = lib.mkIf config.programs.fish.enable (
      lib.mapAttrs'
        (name: _: {
          name = "fish/conf.d/${name}";
          value.source = source (
            ./config/shell + "/${name}"
          ) "modules/home-manager/programs/cli/config/shell/${name}";
        })
        (
          lib.filterAttrs (name: type: type == "regular" && lib.hasSuffix ".fish" name) (
            builtins.readDir ./config/shell
          )
        )
      # functions/ is a pure native config tree, so it gets a whole-directory
      # link (conf.d above stays selective because it is mixed-ownership). The
      # repo does not use programs.fish.functions, so there is no collision.
      // {
        "fish/functions" = {
          source = source ./config/shell/functions "modules/home-manager/programs/cli/config/shell/functions";
        };
      }
    );

    programs.starship.settings = lib.mkIf config.programs.starship.enable {
      "$schema" = "https://starship.rs/config-schema.json";
      "palette" = if config.dotfiles.appearance.enable then "base16" else "dotfiles";
      "scan_timeout" = 500;
      "command_timeout" = 1000;
      "container" = {
        "format" = "[$symbol \\[$name\\]]($style) ";
      };
      "hostname" = {
        "ssh_only" = false;
        "format" = "on [$hostname](bold red) [$ssh_symbol](bold blue) ";
        "disabled" = false;
      };
      # Per-shell badge with its own colour. The native shell module only accepts
      # one colour and always renders next to the character, so each shell gets a
      # custom module gated on STARSHIP_SHELL (exported by every starship init).
      # Custom modules expand at $custom, i.e. at the end of the info line.
      "shell"."disabled" = true;
      "custom"."shell-fish" = {
        "command" = "true";
        "when" = ''test "$STARSHIP_SHELL" = fish'';
        "format" = "[fish](bold cyan) ";
      };
      "custom"."shell-bash" = {
        "command" = "true";
        "when" = ''test "$STARSHIP_SHELL" = bash'';
        "format" = "[bash](bold green) ";
      };
      "custom"."shell-zsh" = {
        "command" = "true";
        "when" = ''test "$STARSHIP_SHELL" = zsh'';
        "format" = "[zsh](bold yellow) ";
      };
      palettes.${if config.dotfiles.appearance.enable then "base16" else "dotfiles"} = lib.mapAttrs (
        _: role: colours.${role}
      ) roles;
    };
  };
}
