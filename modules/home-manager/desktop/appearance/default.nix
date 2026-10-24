{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.dotfiles.desktop.appearance;
  registry = import ../../../../themes { inherit pkgs; };
  colors = config.lib.stylix.colors;
  c = colors.withHashtag;
  palette = lib.genAttrs (map (n: "base${n}") [
    "00"
    "01"
    "02"
    "03"
    "04"
    "05"
    "06"
    "07"
    "08"
    "09"
    "0A"
    "0B"
    "0C"
    "0D"
    "0E"
    "0F"
  ]) (n: c.${n});
  themePackage = (import ../../../../lib/runtime-script.nix { inherit pkgs lib; }) {
    name = "dotfiles-theme";
    source = ./theme-switch;
    runtimeInputs = [
      pkgs.bash
      pkgs.coreutils
      pkgs.jq
      pkgs.util-linux
    ];
  };
  state = "${config.xdg.stateHome}/dotfiles/theme";
  # Noctalia consumes the selected Stylix palette; it does not generate colours.
  noctaliaPalette = {
    mPrimary = c.base0B;
    mOnPrimary = c.base00;
    mSecondary = c.base0D;
    mOnSecondary = c.base00;
    mTertiary = c.base0E;
    mOnTertiary = c.base00;
    mError = c.base08;
    mOnError = c.base00;
    mSurface = c.base00;
    mOnSurface = c.base05;
    mSurfaceVariant = c.base01;
    mOnSurfaceVariant = c.base04;
    mOutline = c.base03;
    mShadow = c.base00;
    mHover = c.base02;
    mOnHover = c.base05;
    terminal = {
      background = c.base00;
      foreground = c.base05;
      cursor = c.base05;
      cursorText = c.base00;
      selectionBg = c.base02;
      selectionFg = c.base05;
      normal = {
        black = c.base00;
        red = c.base08;
        green = c.base0B;
        yellow = c.base0A;
        blue = c.base0D;
        magenta = c.base0E;
        cyan = c.base0C;
        white = c.base05;
      };
      bright = {
        black = c.base03;
        red = c.base08;
        green = c.base0B;
        yellow = c.base0A;
        blue = c.base0D;
        magenta = c.base0E;
        cyan = c.base0C;
        white = c.base07;
      };
    };
  };
in
{
  imports = [ inputs.stylix.homeModules.stylix ];
  options.dotfiles.desktop.appearance = {
    enable = lib.mkEnableOption "Stylix appearance and prebuilt theme variants";
    theme = lib.mkOption {
      type = lib.types.enum (builtins.attrNames registry);
      default = "gruvbox-dark";
      description = "Initial theme; later selections are saved in user state.";
    };
    isVariant = lib.mkOption {
      type = lib.types.bool;
      default = false;
      internal = true;
    };
  };
  # Importing the catalogue alone remains inert.
  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        stylix =
          (import ../../../../themes/style.nix {
            inherit pkgs;
            theme = cfg.theme;
          })
          // {
            targets = {
              gtk = {
                enable = true;
                flatpakSupport.enable = false;
              };
              qt.enable = true;
              rofi.enable = config.dotfiles.desktop.rofi.enable;
              btop.enable = config.dotfiles.terminal.btop.enable;
              bat.enable = config.dotfiles.terminal.bat.enable;
              yazi.enable = config.dotfiles.terminal.yazi.enable;
            };
          };
        home.packages = [
          themePackage
          pkgs.nerd-fonts.symbols-only
          pkgs.corefonts
          pkgs.eb-garamond
        ];
        fonts.fontconfig = {
          enable = true;
          defaultFonts = {
            serif = [ "DejaVu Serif" ];
            sansSerif = [ "Inter" ];
            monospace = [
              "Fira Code"
              "Symbols Nerd Font Mono"
            ];
          };
        };
        xdg.configFile."dotfiles-theme/catalogue.json".text = builtins.toJSON {
          themes = builtins.attrNames registry;
          default = cfg.theme;
        };
        xdg.configFile."dotfiles-theme/current".text = cfg.theme + "\n";
        # Shared nvf binaries read this optional data file, keeping package paths
        # identical across specialisations and providing an embedded standalone fallback.
        xdg.configFile."dotfiles-theme/neovim.lua".text = ''
          return vim.json.decode([=[${
            builtins.toJSON {
              inherit palette;
              polarity = config.stylix.polarity;
            }
          }]=])
        '';
        specialisation = lib.mkIf (!cfg.isVariant) (
          lib.mapAttrs (name: _: {
            configuration.dotfiles.desktop.appearance = {
              theme = lib.mkForce name;
              isVariant = true;
            };
          }) registry
        );
        home.activation.themeSelection = lib.hm.dag.entryAfter [ "reloadSystemd" ] (
          if cfg.isVariant then
            ''
              run mkdir -p ${lib.escapeShellArg state}
              run ${pkgs.coreutils}/bin/install -m 600 ${pkgs.writeText "selected-theme" cfg.theme} ${lib.escapeShellArg "${state}/selected"}
            ''
          else
            ''
              run mkdir -p ${lib.escapeShellArg state}
              run ${pkgs.nix}/bin/nix-store --realise "$newGenPath" --add-root ${lib.escapeShellArg "${state}/root"} --indirect >/dev/null
              selected=${lib.escapeShellArg cfg.theme}
              if [ -r ${lib.escapeShellArg "${state}/selected"} ]; then
                saved=$(${pkgs.coreutils}/bin/cat ${lib.escapeShellArg "${state}/selected"})
                case "$saved" in ${lib.concatStringsSep "|" (builtins.attrNames registry)}) selected=$saved ;; esac
              fi
              if [ "$selected" != ${lib.escapeShellArg cfg.theme} ]; then
                run "$newGenPath/specialisation/$selected/activate"
              else
                run ${pkgs.coreutils}/bin/install -m 600 ${pkgs.writeText "selected-theme" cfg.theme} ${lib.escapeShellArg "${state}/selected"}
              fi
            ''
        );
        home.activation.reloadAppearance = lib.hm.dag.entryAfter [ "themeSelection" ] ''
          if [ "$(${pkgs.coreutils}/bin/cat ${lib.escapeShellArg "${config.xdg.configHome}/dotfiles-theme/current"})" = ${lib.escapeShellArg cfg.theme} ]; then
          : # A valid shell body even when no reloadable applications are selected.
          ${lib.optionalString config.dotfiles.terminal.kitty.enable ''
            run ${pkgs.procps}/bin/pkill -USR1 -x kitty || test $? -eq 1
          ''}
          ${lib.optionalString config.dotfiles.terminal.tmux.enable ''
            run ${pkgs.tmux}/bin/tmux source-file ${lib.escapeShellArg "${config.xdg.configHome}/tmux/theme.conf"} 2>/dev/null || true
          ''}
          ${lib.optionalString config.dotfiles.desktop.noctalia.enable ''
            if ${pkgs.systemd}/bin/systemctl --user is-active --quiet noctalia.service; then
              run ${
                inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
              }/bin/noctalia ipc config-reload || true
              run ${
                inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
              }/bin/noctalia ipc color-scheme-set custom stylix || true
              run ${
                inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
              }/bin/noctalia ipc theme-mode-set ${config.stylix.polarity} || true
            fi
          ''}
          fi
        '';
      }
      (lib.mkIf config.dotfiles.editors.vim.enable {
        home.file.".vim/colors/dotfiles.vim".source = colors {
          templateRepo = inputs.stylix.inputs.base16-vim;
          target = "base16";
        };
      })
      (lib.mkIf config.dotfiles.terminal.herdr.enable {
        xdg.configFile."herdr/config.toml".text =
          builtins.readFile ../../terminal/herdr/config/config.toml
          + ''
            [theme.custom]
            panel_bg = "${c.base01}"
            accent = "${c.base0B}"
            green = "${c.base0B}"
            blue = "${c.base0D}"
            red = "${c.base08}"
            yellow = "${c.base0A}"
          '';
      })
      (lib.mkIf config.dotfiles.desktop.noctalia.enable {
        programs.noctalia.customPalettes.stylix = {
          dark = noctaliaPalette;
          light = noctaliaPalette;
        };
        programs.noctalia.settings.theme = {
          mode = config.stylix.polarity;
          source = "custom";
          custom_palette = "stylix";
          templates = {
            enable_builtin_templates = false;
            builtin_ids = [ ];
            enable_community_templates = false;
          };
        };
      })
      (lib.mkIf config.dotfiles.terminal.kitty.enable {
        xdg.configFile."kitty/theme.conf".text = ''
          font_family ${config.stylix.fonts.monospace.name}
          font_size ${toString config.stylix.fonts.sizes.terminal}
          background ${c.base00}
          foreground ${c.base05}
          cursor ${c.base05}
          selection_background ${c.base02}
          selection_foreground ${c.base05}
          ${lib.concatStringsSep "\n" (
            lib.imap0 (i: name: "color${toString i} ${c.${name}}") [
              "base00"
              "base08"
              "base0B"
              "base0A"
              "base0D"
              "base0E"
              "base0C"
              "base05"
              "base03"
              "base08"
              "base0B"
              "base0A"
              "base0D"
              "base0E"
              "base0C"
              "base07"
            ]
          )}
        '';
      })
      (lib.mkIf config.dotfiles.terminal.tmux.enable {
        xdg.configFile."tmux/theme.conf".text = ''
          set -g status-style "bg=${c.base00},fg=${c.base05}"
          set -g pane-border-style "fg=${c.base03}"
          set -g pane-active-border-style "fg=${c.base0B}"
          set -g message-style "bg=${c.base01},fg=${c.base05}"
          setw -g window-status-current-style "bg=${c.base02},fg=${c.base0B},bold"
        '';
      })
      (lib.mkIf config.dotfiles.terminal.fish.enable {
        xdg.configFile."fish/conf.d/06-theme.fish".text = ''
          set -g fish_color_normal ${colors.base05}
          set -g fish_color_command ${colors.base0D}
          set -g fish_color_keyword ${colors.base0E}
          set -g fish_color_quote ${colors.base0B}
          set -g fish_color_redirection ${colors.base0C}
          set -g fish_color_end ${colors.base09}
          set -g fish_color_error ${colors.base08}
          set -g fish_color_param ${colors.base05}
          set -g fish_color_comment ${colors.base03}
          set -g fish_color_autosuggestion ${colors.base03}
          set -g fish_color_search_match --background=${colors.base02}
          set -g fish_color_selection --background=${colors.base02}
        '';
      })
      (lib.mkIf config.dotfiles.terminal.fzf.enable {
        xdg.configFile."fzf/theme.opts".text =
          "--color=fg:${c.base05},bg:${c.base00},hl:${c.base0D},fg+:${c.base05},bg+:${c.base01},hl+:${c.base0D},info:${c.base0A},prompt:${c.base0B},pointer:${c.base08},marker:${c.base0C},spinner:${c.base0E},header:${c.base0D},border:${c.base03}\n";
      })
      (lib.mkIf config.dotfiles.desktop.mango.enable {
        xdg.configFile."mango/theme.conf".text = ''
          root_color=0x${colors.base00}ff
          border_color=0x${colors.base03}ff
          focus_color=0x${colors.base0B}ff
        '';
      })
    ]
  );
}
