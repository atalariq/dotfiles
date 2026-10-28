{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.dotfiles.appearance;
  registry = import ./schemes.nix { inherit pkgs; };
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
  options.dotfiles.appearance = {
    enable = lib.mkEnableOption "Stylix appearance";
    gui = lib.mkEnableOption "platform-specific GUI appearance targets";
    theme = lib.mkOption {
      type = lib.types.enum (builtins.attrNames registry);
      default = "gruvbox-dark";
      description = "Declarative theme selection; rebuild to change it.";
    };

  };
  # Importing the catalogue alone remains inert.
  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        stylix =
          (import ./style.nix {
            inherit pkgs;
            inherit (cfg) theme;
          })
          // {
            cursor =
              if pkgs.stdenv.hostPlatform.isLinux && cfg.gui then
                (import ./style.nix { inherit pkgs; }).cursor
              else
                null;
            icons = (import ./style.nix { inherit pkgs; }).icons // {
              enable = pkgs.stdenv.hostPlatform.isLinux && cfg.gui;
            };
            opacity.terminal = 0.96;
            targets = {
              gtk = {
                enable = pkgs.stdenv.hostPlatform.isLinux && config.dotfiles.appearance.gui;
                flatpakSupport.enable = false;
              };
              qt.enable = pkgs.stdenv.hostPlatform.isLinux && config.dotfiles.appearance.gui;
              starship.enable = config.programs.starship.enable;
              kitty.enable = config.programs.kitty.enable;
              fish.enable = config.programs.fish.enable;
              fzf.enable = config.programs.fzf.enable;
              btop.enable = config.programs.btop.enable;
              bat.enable = config.programs.bat.enable;
              yazi.enable = config.programs.yazi.enable;
            };
          };
        home.packages = [
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
        # The shared nvf package reads this generated palette, with a standalone fallback.
        xdg.configFile."dotfiles-theme/neovim.lua".text = ''
          return vim.json.decode([=[${
            builtins.toJSON {
              inherit palette;
              polarity = config.stylix.polarity;
            }
          }]=])
        '';

      }
      (lib.mkIf config.dotfiles.programs.vim.enable {
        home.file.".vim/colors/dotfiles.vim".source = colors {
          templateRepo = inputs.stylix.inputs.base16-vim;
          target = "base16";
        };
      })
      (lib.mkIf config.programs.fastfetch.enable {
        programs.fastfetch.settings = {
          logo.color."1" = c.base0B;
          display.color = {
            keys = c.base0B;
            title = c.base0D;
          };
        };
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
      (lib.mkIf config.dotfiles.programs.tmux.enable {
        xdg.configFile."tmux/theme.conf".text = ''
          set -g status-style "bg=${c.base00},fg=${c.base05}"
          set -g pane-border-style "fg=${c.base03}"
          set -g pane-active-border-style "fg=${c.base0B}"
          set -g message-style "bg=${c.base01},fg=${c.base05}"
          setw -g window-status-current-style "bg=${c.base02},fg=${c.base0B},bold"
        '';
      })
      (lib.mkIf config.dotfiles.desktop.umbriel.enable {
        dotfiles.desktop.umbriel.settings = {
          input.cursor = {
            theme = config.stylix.cursor.name;
            size = config.stylix.cursor.size;
          };
          colors = {
            background = c.base00;
            backdrop = c.base00;
            text_primary = c.base05;
            text_muted = c.base04;
            accent_primary = c.base0B;
            accent_secondary = c.base0D;
            warning = c.base0A;
            error = c.base08;
            border = {
              focused = c.base0B;
              unfocused = c.base03;
              outer = c.base01;
            };
          };
        };
      })
    ]
  );
}
