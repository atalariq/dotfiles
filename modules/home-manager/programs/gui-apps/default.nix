{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.dotfiles.programs.gui.enable = lib.mkEnableOption "the gui package bundle";

  # Graphical applications and desktop utilities that have no dedicated Home
  # Manager module: browsers, file manager, viewers, chat clients and media
  # creation/playback. kitty and obs-studio keep their own modules because they
  # carry granular native config.
  config = lib.mkIf config.dotfiles.programs.gui.enable {
    home.packages = with pkgs; [
      brave-origin
      google-chrome
      nautilus
      file-roller
      obsidian
      readest
      localsend
      scrcpy
      wdisplays
      wl-mirror
      figma-linux
      discord
      slack
      gimp
      inkscape
      blender
      kdePackages.kdenlive
      nicotine-plus
      anki
      libva-utils
    ];

    # Bitwarden Desktop only looks for Brave at its hardcoded
    # `Brave-Browser` profile directory, while this host runs Brave Origin.
    # The app creates the native-messaging manifest and proxy inside whatever
    # directory it finds, so a compatibility symlink is enough. This uses an
    # activation entry instead of `xdg.configFile` because the parent
    # `BraveSoftware` directory holds unmanaged browser state that a managed
    # symlink would shadow. The link is only created when the Origin profile
    # exists and nothing real occupies the Brave name.
    home.activation.braveOriginBitwardenBridge = lib.mkIf pkgs.stdenv.hostPlatform.isLinux (
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        brave_dir="${config.xdg.configHome}/BraveSoftware/Brave-Origin"
        browser_dir="${config.xdg.configHome}/BraveSoftware/Brave-Browser"
        if [[ -d $brave_dir && (! -e $browser_dir || -L $browser_dir) ]]; then
          run ln -sfn -- $brave_dir $browser_dir
        fi
      ''
    );
  };
}
