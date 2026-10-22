{
  config,
  lib,
  pkgs,
  inputs,
  checkout,
  ...
}:
let
  # Noctalia writes its include at runtime; validate against an empty fragment.
  validatedConfig = pkgs.runCommand "mango-config-check" { } ''
    export HOME="$TMPDIR/home"
    mkdir -p "$HOME/.config/mango"
    touch "$HOME/.config/mango/noctalia.conf"
    cp ${./config/config.conf} "$HOME/.config/mango/config.conf"
    ${config.wayland.windowManager.mango.package}/bin/mango -p -c "$HOME/.config/mango/config.conf"
    touch "$out"
  '';
in
{
  imports = [ inputs.mangowm.hmModules.mango ];
  wayland.windowManager.mango = {
    enable = true;
    systemd.enable = true;
    autostart_sh = "systemctl --user start noctalia.service";
  };
  home.extraDependencies = [ validatedConfig ];
  xdg.configFile."mango/config.conf".source = lib.mkForce (
    config.lib.file.mkOutOfStoreSymlink "${checkout}/home/mango/config/config.conf"
  );
  xdg.configFile."mango/script".source =
    config.lib.file.mkOutOfStoreSymlink "${checkout}/home/mango/config/script";
  xdg.configFile."xdg-desktop-portal-termfilechooser/config".text = ''
    [filechooser]
    cmd=${checkout}/home/mango/config/yazi-chooser
    default_dir=${config.home.homeDirectory}
    env=PATH=${
      lib.makeBinPath [
        pkgs.kitty
        pkgs.yazi
        pkgs.coreutils
      ]
    }:/run/current-system/sw/bin
    open_mode=suggested
    save_mode=suggested
  '';
  xdg.configFile."xdg-desktop-portal/mango-portals.conf".text = ''
    [preferred]
    default=gtk
    org.freedesktop.impl.portal.Secret=gnome-keyring
    org.freedesktop.impl.portal.ScreenCast=wlr
    org.freedesktop.impl.portal.Screenshot=wlr
    org.freedesktop.impl.portal.Inhibit=none
    org.freedesktop.impl.portal.FileChooser=termfilechooser
  '';
  home.activation.mangoThemeFragment = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p ${lib.escapeShellArg "${config.xdg.configHome}/mango"}
    if [ ! -e ${lib.escapeShellArg "${config.xdg.configHome}/mango/noctalia.conf"} ]; then
      run touch ${lib.escapeShellArg "${config.xdg.configHome}/mango/noctalia.conf"}
    fi
  '';
}
