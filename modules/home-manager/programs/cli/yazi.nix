{
  config,
  lib,
  pkgs,
  ...
}:
let
  live = config.dotfiles.deployment.mode == "live";
  checkout = config.dotfiles.deployment.checkout;
in
{
  options.dotfiles.programs.cli.yazi.enable = lib.mkEnableOption "yazi configuration";

  config = lib.mkIf config.dotfiles.programs.cli.yazi.enable {
    programs.yazi = {
      enable = true;
      # init.lua and plugins are linked below so live mode actually picks up
      # edits; initLua would otherwise be frozen at evaluation time.
      enableBashIntegration = false;
      enableFishIntegration = false;
      enableZshIntegration = false;
      keymap = {
        "mgr" = {
          "prepend_keymap" = [
            {
              "on" = "!";
              "for" = "unix";
              "run" = "shell \"$SHELL\" --block";
              "desc" = "Open $SHELL here";
            }
            {
              "on" = "<A-q>";
              "run" = "close";
              "desc" = "Close the current tab, or quit if it's last";
            }
            {
              "on" = "q";
              "run" = "plugin confirm-quit";
              "desc" = "Confirm before quitting if multiple tabs are open";
            }
            {
              "on" = "<F3>";
              "run" = "plugin mediainfo -- toggle-metadata";
              "desc" = "Toggle media preview metadata";
            }
            {
              "on" = "<F4>";
              "run" = "plugin mediainfo -- toggle-preview";
              "desc" = "Toggle media preview image";
            }
            {
              "on" = "<F6>";
              "run" = "plugin mediainfo -- hide-metadata";
              "desc" = "Hide media preview metadata";
            }
            {
              "on" = "<F7>";
              "run" = "plugin mediainfo -- hide-preview";
              "desc" = "Hide media preview image";
            }
            {
              "on" = "<F8>";
              "run" = "plugin mediainfo -- show-metadata";
              "desc" = "Show media preview metadata";
            }
            {
              "on" = "<F9>";
              "run" = "plugin mediainfo -- show-preview";
              "desc" = "Show media preview image";
            }
            {
              "on" = "<F5>";
              "run" = "plugin mediainfo -- reset";
              "desc" = "Reset media preview to default settings";
            }
            {
              "on" = "<F10>";
              "run" = "plugin mediainfo -- --toggle-preview --toggle-metadata";
              "desc" = "Toggle both media preview image and metadata";
            }
            {
              "on" = "<F11>";
              "run" = "plugin mediainfo -- --show-preview --hide-metadata";
              "desc" = "Show media preview image and hide metadata";
            }
            {
              "on" = [ "C" ];
              "run" = "plugin ouch";
              "desc" = "Compress with ouch";
            }
          ];
        };
      };
      settings = {
        "mgr" = {
          "ratio" = [
            1
            4
            3
          ];
          "sort_by" = "natural";
          "sort_dir_first" = true;
          "sort_fallback" = "alphabetical";
          "show_hidden" = false;
          "show_symlink" = false;
          "scrolloff" = 5;
          "mouse_events" = [
            "click"
            "scroll"
          ];
        };
        "preview" = {
          "wrap" = "no";
          "tab_size" = 2;
          "image_delay" = 40;
          "image_quality" = 70;
        };
        "tasks" = {
          "image_alloc" = 536870912;
        };
        "opener" = {
          "extract" = [
            {
              "run" = "ouch d -y %s";
              "desc" = "Extract with ouch";
              "for" = "windows";
            }
            {
              "run" = "ouch d -y %s";
              "desc" = "Extract with ouch";
              "for" = "unix";
            }
          ];
        };
        "plugin" = {
          "prepend_preloaders" = [
            {
              "url" = "/remote/**";
              "run" = "noop";
            }
            {
              "mime" = "{audio,video,image}/*";
              "run" = "mediainfo";
            }
            {
              "mime" = "application/subrip";
              "run" = "mediainfo";
            }
          ];
          "prepend_previewers" = [
            {
              "mime" = "application/{*zip,tar,bzip2,7z*,rar,xz,zstd,java-archive}";
              "run" = "ouch --show-file-icons --list-view";
            }
            {
              "mime" = "{audio,video,image}/*";
              "run" = "mediainfo";
            }
            {
              "mime" = "application/subrip";
              "run" = "mediainfo";
            }
          ];
        };
      };

    };
    home.packages = with pkgs; [
      ouch
      mediainfo
      ffmpeg
      imagemagick
    ];
    xdg.configFile."yazi/init.lua" = {
      source =
        if live then
          config.lib.file.mkOutOfStoreSymlink "${checkout}/modules/home-manager/programs/cli/config/yazi/init.lua"
        else
          ./config/yazi/init.lua;
    };
    xdg.configFile."yazi/plugins" = {
      source =
        if live then
          config.lib.file.mkOutOfStoreSymlink "${checkout}/modules/home-manager/programs/cli/config/yazi/plugins"
        else
          ./config/yazi/plugins;
    };
    xdg.configFile."fish/conf.d/yazi.fish" = lib.mkIf config.programs.fish.enable {
      source =
        if live then
          config.lib.file.mkOutOfStoreSymlink "${checkout}/modules/home-manager/programs/cli/config/yazi/fish.fish"
        else
          ./config/yazi/fish.fish;
    };
  };

}
