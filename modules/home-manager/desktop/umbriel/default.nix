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
  screenshotBinds =
    lib.concatMapAttrs
      (key: _: {
        "${key}" = bind "spawn:shot area";
        "Ctrl+${key}" = bind "spawn:shot screen";
        "Alt+${key}" = bind "spawn:shot active";
        "Shift+${key}" = bind "spawn:shot annotate";
        "Mod+${key}" = bind "spawn:shot ocr";
      })
      {
        Print = null;
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
        assertion =
          pkgs.stdenv.hostPlatform.isLinux
          && config.dotfiles.desktop.noctalia.enable
          && config.dotfiles.desktop.helpers.enable
          && config.dotfiles.programs.capture.enable;
        message = "Umbriel requires Linux, Noctalia, desktop helpers and capture.";
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
        // builtins.listToAttrs (
          map (shortcut: {
            name = "Ctrl+Mod+Alt+${lib.optionalString shortcut.shift "Shift+"}${shortcut.key}";
            value = bind "spawn:${shortcut.command}";
          }) (import ../shortcuts.nix)
        )
        // screenshotBinds
        // {
          "Mod+Return" = bind "spawn:kitty";
          "Mod+Shift+Return" = bind "spawn:kitty";
          "Mod+W" = bind "spawn:brave-origin";
          "Mod+Q" = bind "spawn:desktop-close";
          "Mod+Shift+Alt+Q" = bind "session-quit";
          "Mod+Space" = bind "spawn:controller noctalia launcher";
          "Mod+A" = bind "spawn:controller noctalia launcher";
          "Mod+V" = bind "spawn:controller noctalia clipboard";
          "Mod+E" = bind "spawn:controller noctalia emoji";
          "Mod+C" = bind "spawn:controller noctalia control-center";
          "Mod+N" = bind "spawn:controller noctalia notifications";
          "Mod+Y" = bind "spawn:controller noctalia wallpaper";
          "Mod+Comma" = bind "spawn:controller noctalia settings";
          "Mod+Escape" = bind "spawn:controller noctalia session";
          "Mod+P" = bind "spawn:desktop-window-info";
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
          "XF86AudioRaiseVolume" = "spawn:controller volume up";
          "XF86AudioLowerVolume" = "spawn:controller volume down";
          "XF86AudioMute" = bind "spawn:controller volume mute";
          "XF86AudioPlay" = bind "spawn:controller player toggle";
          "XF86AudioNext" = bind "spawn:controller player next";
          "XF86AudioPrev" = bind "spawn:controller player prev";
          "XF86MonBrightnessUp" = "spawn:controller brightness up";
          "XF86MonBrightnessDown" = "spawn:controller brightness down";
          "XF86KbdBrightnessUp" = "spawn:controller kbdlight up";
          "XF86KbdBrightnessDown" = "spawn:controller kbdlight down";
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
      org.freedesktop.impl.portal.FileChooser=termfilechooser
    '';
  };
}
