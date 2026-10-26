{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.dotfiles.desktop.umbriel;
  format = pkgs.formats.toml { };
  generated = format.generate "umbriel-config.toml" cfg.settings;
  bind = action: {
    inherit action;
    repeat = false;
  };
  workspaceBinds = builtins.listToAttrs (
    lib.concatMap (n: [
      {
        name = "Mod+${toString n}";
        value = "workspace-switch:${toString n}";
      }
      {
        name = "Mod+Shift+${toString n}";
        value = "window-move-to-workspace:${toString n}";
      }
    ]) (lib.range 1 9)
  );
  validated = pkgs.runCommand "umbriel-config-check" { } ''
    export HOME="$TMPDIR/home"
    mkdir -p "$HOME"
    ${pkgs.umbriel}/bin/umbriel config validate -c ${generated}
    touch "$out"
  '';
in
{
  options.dotfiles.desktop.umbriel = {
    enable = lib.mkEnableOption "Umbriel scrolling desktop";
    settings = lib.mkOption {
      inherit (format) type;
      default = { };
      description = "Umbriel TOML settings; outputs belong in the host configuration.";
    };
  };
  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = pkgs.stdenv.hostPlatform.isLinux && config.dotfiles.desktop.noctalia.enable;
        message = "Umbriel requires Linux and Noctalia.";
      }
    ];
    home.packages = [
      pkgs.umbriel
      pkgs.xwayland
    ];
    home.extraDependencies = [ validated ];
    xdg.configFile."umbriel/config.toml".source = generated;
    # The pinned HM has no Umbriel module. Keep this adapter thin and use the
    # packaged session launcher/units rather than inventing another lifecycle.
    dotfiles.desktop.umbriel.settings = {
      general = {
        mod_key = "Super";
        autostart = [ "systemctl --user start noctalia.service look.service" ];
      };
      layout = {
        mode = "scrolling";
        gap = 4;
        extent_presets = [
          0.5
          0.8
          1.0
        ];
        scrolling.default_extent_fraction = 0.5;
      };
      appearance = {
        border_width = 1;
        corner_radius = 16;
        blur.enabled = false;
        shadow.enabled = false;
      };
      input = {
        keyboard = {
          layout = "us";
          options = "ctrl:swap_rwin_rctl";
          repeat_rate = 30;
          repeat_delay = 350;
          numlock_toggle = false;
        };
        touchpad = {
          tap = true;
          natural_scroll = true;
          disable_while_typing = true;
          click_method = "clickfinger";
        };
        focus.follows_mouse = true;
      };
      keybinds =
        workspaceBinds
        // lib.optionalAttrs config.dotfiles.desktop.shelf.enable {
          "Ctrl+Mod+Alt+S" = bind "spawn:pluto toggle";
        }
        // {
          "Mod+Return" = bind "spawn:kitty";
          "Mod+Shift+Return" = bind "spawn:kitty";
          "Mod+W" = bind "spawn:brave-origin";
          "Mod+Shift+Alt+Q" = bind "session-quit";
          "Mod+Space" = bind "spawn:lookapp --toggle";
          "Mod+A" = bind "spawn:lookapp --toggle";
          "Mod+V" = bind "spawn:lookapp clipboard";
          "Mod+E" = bind "spawn:lookapp --toggle";
          "Mod+C" = bind "spawn:noctalia msg panel-toggle control-center";
          "Mod+N" = bind "spawn:noctalia msg panel-toggle notifications";
          "Mod+Y" = bind "spawn:noctalia msg panel-toggle wallpaper";
          "Mod+Comma" = bind "spawn:noctalia msg settings-toggle";
          "Mod+Escape" = bind "spawn:noctalia msg panel-toggle session";
          "Mod+H" = "window-focus-left";
          "Mod+J" = "window-focus-down";
          "Mod+K" = "window-focus-up";
          "Mod+L" = "window-focus-right";
          "Mod+Left" = "window-focus-left";
          "Mod+Down" = "window-focus-down";
          "Mod+Up" = "window-focus-up";
          "Mod+Right" = "window-focus-right";
          "Mod+Shift+H" = "column-move-left";
          "Mod+Shift+J" = "window-move-down";
          "Mod+Shift+K" = "window-move-up";
          "Mod+Shift+L" = "column-move-right";
          "Mod+Shift+Space" = bind "window-toggle-floating";
          "Mod+Shift+F" = bind "window-toggle-fullscreen";
          "Mod+M" = bind "window-toggle-maximize-to-edges";
          "Mod+O" = bind "overview-toggle";
          "Mod+X" = "window-cycle-primary-extent";
          "Mod+Minus" = bind "scratchpad-toggle:terminal";
          "Mod+Grave" = bind "scratchpad-toggle:terminal";
          "Mod+Shift+Minus" = bind "window-move-to-scratchpad:terminal";
          "Mod+BracketLeft" = "workspace-previous";
          "Mod+BracketRight" = "workspace-next";
          "XF86AudioRaiseVolume" = "spawn:noctalia msg volume-up";
          "XF86AudioLowerVolume" = "spawn:noctalia msg volume-down";
          "XF86AudioMute" = bind "spawn:noctalia msg volume-mute";
          "XF86AudioPlay" = bind "spawn:noctalia msg media toggle";
          "XF86AudioNext" = bind "spawn:noctalia msg media next";
          "XF86AudioPrev" = bind "spawn:noctalia msg media prev";
          "XF86MonBrightnessUp" = "spawn:noctalia msg brightness-up";
          "XF86MonBrightnessDown" = "spawn:noctalia msg brightness-down";
          "XF86KbdBrightnessUp" = "spawn:brightnessctl --device=*kbd_backlight set 1+";
          "XF86KbdBrightnessDown" = "spawn:brightnessctl --device=*kbd_backlight set 1-";
        };
      scratchpad = [
        {
          name = "terminal";
          spawn_when_empty = "kitty --app-id=scratchpad";
        }
      ];
      window_rule = [
        {
          match.app_id = "^scratchpad$";
          default_scratchpad = "terminal";
          default_floating_size_px = {
            width = 1080;
            height = 720;
          };
        }
        {
          match.app_id = "^(com[.]gabm[.]satty|it[.]catboy[.]ripdrag|termfilechooser|files|org[.]gnome[.]Nautilus|pavucontrol|org[.]pulseaudio[.]pavucontrol|blueman-manager|org[.]blueman[.]Manager|nm-connection-editor|pinentry.*|.*PolicyKit.*|dev[.]noctalia[.]Noctalia|dev[.]noctalia[.]UmbrielSharePicker)$";
          default_floating = true;
        }
        {
          match.title = "^(Picture.in.picture|Open File.*|Open Folder|Save As|Save File|Choose wallpaper|Steam Guard)$";
          default_floating = true;
        }
      ];
    };
    xdg.configFile."xdg-desktop-portal/umbriel-portals.conf".text = ''
      [preferred]
      default=umbriel;gtk
      org.freedesktop.impl.portal.Secret=gnome-keyring
      org.freedesktop.impl.portal.ScreenCast=umbriel
      org.freedesktop.impl.portal.Screenshot=umbriel
      org.freedesktop.impl.portal.FileChooser=gtk
    '';
  };
}
