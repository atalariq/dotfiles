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
              # The Stylix nvf target still writes the deprecated
              # `lualine.theme` option. nvf's theme is wired manually in
              # programs/cli/neovim.nix instead; the wana fallback handles
              # hosts without Stylix.
              nvf.enable = false;
              fish.enable = config.programs.fish.enable;
              fzf.enable = config.programs.fzf.enable;
              btop.enable = config.programs.btop.enable;
              bat.enable = config.programs.bat.enable;
              yazi.enable = config.programs.yazi.enable;
              # Helix's target generates themes/stylix.toml and also sets
              # settings.theme; programs/cli/helix.nix keeps config.toml live
              # and forces the settings half away.
              helix.enable = config.programs.helix.enable;
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
      (lib.mkIf config.dotfiles.programs.cli.vim.enable {
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
      (lib.mkIf config.dotfiles.programs.gui.ghostty.enable {
        # Ghostty loads this theme from the live config's `theme = stylix`.
        xdg.configFile."ghostty/themes/stylix".text = ''
          background = ${c.base00}
          foreground = ${c.base05}
          cursor-color = ${c.base05}
          selection-background = ${c.base02}
          selection-foreground = ${c.base05}
          palette = 0=${c.base00}
          palette = 1=${c.base08}
          palette = 2=${c.base0B}
          palette = 3=${c.base0A}
          palette = 4=${c.base0D}
          palette = 5=${c.base0E}
          palette = 6=${c.base0C}
          palette = 7=${c.base05}
          palette = 8=${c.base03}
          palette = 9=${c.base08}
          palette = 10=${c.base0B}
          palette = 11=${c.base0A}
          palette = 12=${c.base0D}
          palette = 13=${c.base0E}
          palette = 14=${c.base0C}
          palette = 15=${c.base07}
        '';
      })
      (lib.mkIf config.dotfiles.programs.cli.tmux.enable {
        # tmux.conf owns layout and formats; these variables are the shared
        # palette contract with Stylix.
        xdg.configFile."tmux/theme.conf".text = ''
          set -g @thm_bg "${c.base00}"
          set -g @thm_fg "${c.base05}"
          set -g @thm_muted "${c.base03}"
          set -g @thm_surface "${c.base01}"
          set -g @thm_surface_alt "${c.base02}"
          set -g @thm_accent "${c.base0B}"
          set -g @thm_accent_alt "${c.base0D}"
          set -g @thm_alert "${c.base08}"
          set -g @thm_warn "${c.base0A}"
        '';
      })
    ]
  );
}
