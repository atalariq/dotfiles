{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs.yazi = lib.mkIf config.programs.yazi.enable {
    initLua = builtins.readFile ./config/init.lua;
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
            "on" = "s";
            "run" = "search --via=fd";
            "desc" = "Search files by name via fd";
          }
          {
            "on" = "S";
            "run" = "search --via=rg";
            "desc" = "Search files by content via ripgrep";
          }
          {
            "on" = "<C-s>";
            "run" = "escape --search";
            "desc" = "Cancel the ongoing search";
          }
          {
            "on" = [
              "g"
              "h"
            ];
            "run" = "cd ~";
          }
          {
            "on" = [
              "g"
              "c"
            ];
            "run" = "cd ~/.config";
          }
          {
            "on" = [
              "g"
              "C"
            ];
            "run" = "cd ~/Repos/dotfiles";
          }
          {
            "on" = [
              "g"
              "d"
            ];
            "run" = "cd ~/Downloads";
          }
          {
            "on" = [
              "g"
              "r"
            ];
            "run" = "shell -- ya emit cd \"$(git rev-parse --show-toplevel)\"";
            "desc" = "Go to git root folder";
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
            "on" = "<F12>";
            "run" = "plugin mediainfo -- --show-preview --hide-metadata --reset --show-metadata --hide-preview";
            "desc" = "Show media preview image and hide metadata";
          }
          {
            "on" = [ "C" ];
            "run" = "plugin ouch";
            "desc" = "Compress with ouch";
          }
        ];
      };
      "input" = {
        "prepend_keymap" = [
          {
            "on" = "<Esc>";
            "run" = "close";
            "desc" = "Cancel input";
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
        "image_delay" = 0;
        "image_quality" = 70;
      };
      "tasks" = {
        "image_alloc" = 1073741824;
      };
      "opener" = {
        "extract" = [
          {
            "run" = "ouch d -y %*";
            "desc" = "Extract here with ouch";
            "for" = "windows";
          }
          {
            "run" = "ouch d -y \"$@\"";
            "desc" = "Extract here with ouch";
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
  home.packages = lib.mkIf config.programs.yazi.enable (
    with pkgs;
    [
      ouch
      mediainfo
      ffmpeg
      imagemagick
    ]
  );
  programs.fish.interactiveShellInit =
    lib.mkIf (config.programs.yazi.enable && config.programs.fish.enable)
      ''
        function yazicd --description 'Open Yazi and follow its working directory'
          set -l tmp (mktemp -t yazi-cwd.XXXXX)
          command yazi $argv --cwd-file="$tmp"
          set -l cwd (command cat -- "$tmp")
          command rm -f -- "$tmp"
          if test -n "$cwd"; and test "$cwd" != "$PWD"
            cd -- "$cwd"
          end
        end
        abbr -a fm yazi
        abbr -a yy yazicd
      '';
  xdg.configFile."yazi/plugins" = lib.mkIf config.programs.yazi.enable { source = ./config/plugins; };

}
