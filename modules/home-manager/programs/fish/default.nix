{
  config,
  lib,
  pkgs,
  ...
}:
{
  home.packages = lib.mkIf config.programs.fish.enable [ pkgs.glib ];
  programs.fish = lib.mkIf config.programs.fish.enable {
    shellInit = ''
      # Portable paths; project environments and existing runtime settings take priority.
      set -q XDG_CONFIG_HOME; or set -gx XDG_CONFIG_HOME "$HOME/.config"
      set -q XDG_CACHE_HOME; or set -gx XDG_CACHE_HOME "$HOME/.cache"
      set -q XDG_DATA_HOME; or set -gx XDG_DATA_HOME "$HOME/.local/share"
      set -q XDG_STATE_HOME; or set -gx XDG_STATE_HOME "$HOME/.local/state"

      set -q LOCAL_BIN; or set -gx LOCAL_BIN "$HOME/.local/bin"
      set -q LOCAL_SCRIPT; or set -gx LOCAL_SCRIPT "$HOME/.local/script"
      set -q GOPATH; or set -gx GOPATH "$HOME/.go"
      set -q GOBIN; or set -gx GOBIN "$GOPATH/bin"
      set -q CARGO_HOME; or set -gx CARGO_HOME "$HOME/.cargo"
      set -q RUSTUP_HOME; or set -gx RUSTUP_HOME "$HOME/.rustup"
      set -q PNPM_HOME; or set -gx PNPM_HOME "$XDG_DATA_HOME/pnpm"
      set -q BUN_INSTALL; or set -gx BUN_INSTALL "$HOME/.bun"
      set -q DENO_INSTALL; or set -gx DENO_INSTALL "$HOME/.deno"
      set -q UV_LINK_MODE; or set -gx UV_LINK_MODE copy
      if test -f "$XDG_CONFIG_HOME/python/pythonrc"
          set -gx PYTHONSTARTUP "$XDG_CONFIG_HOME/python/pythonrc"
      end

      # Append existing user directories; never prepend global toolchains over a project.
      for directory in "$GOBIN" "$CARGO_HOME/bin" "$PNPM_HOME" "$BUN_INSTALL/bin" "$DENO_INSTALL/bin" "$LOCAL_BIN" "$LOCAL_SCRIPT"
          if test -d "$directory"; and not contains -- "$directory" $PATH
              set -gx PATH $PATH "$directory"
          end
      end

      # Only configure tools and native resources that actually exist. Fish remains
      # useful when imported alone, and never overwrites an inherited editor choice.
      if not set -q EDITOR
          if command -q nvim
              set -gx EDITOR nvim
          else if command -q vim
              set -gx EDITOR vim
          else
              set -gx EDITOR vi
          end
      end
      set -q VISUAL; or set -gx VISUAL "$EDITOR"
      if command -q less
          set -gx PAGER less
          set -gx LESS '-R -F -X'
      end
      command -q nvim; and set -gx MANPAGER 'nvim +Man!'
      set -l config_home "$HOME/.config"
      set -q XDG_CONFIG_HOME; and set config_home "$XDG_CONFIG_HOME"
      if test -r "$config_home/vale/.vale.ini"
          set -gx VALE_CONFIG_PATH "$config_home/vale/.vale.ini"
      end

      # Exit Vim-Like
      alias :Q exit
      alias :q exit

      # alias cd='pushd'
      # alias pd='popd'

      # alias .. "cd .."
      # alias ... "cd ../.."
      # alias .... "cd ../../.."
      # alias ..... "cd ../../../.."

      alias c clear
      alias h history
      alias j "jobs -l"

      alias df "df -h"
      alias du "du -ch"
      alias free "free -m"
      command -q btop; and alias top btop

      # ── Safer defaults ─────────────────────────────────────
      alias cp "cp -iv"
      alias mv "mv -iv"
      if test (uname) = Linux
          alias rm "rm -Iv"
      else
          alias rm "rm -iv"
      end
      alias mkdir "mkdir -pv"

      if test (uname) = Linux
          alias chown "chown --preserve-root"
          alias chmod "chmod --preserve-root"
          alias chgrp "chgrp --preserve-root"
      end

      alias root "sudo -i"
      alias su "sudo -i"

      # ── Modern replacements ────────────────────────────────
      if command -q eza
          alias ll "eza --icons --group-directories-first -lgh"
          alias lla "eza --icons --group-directories-first -algh"
          alias ls "eza --icons --group-directories-first"
          alias lsa "eza --icons --group-directories-first -a"
          alias lt "eza --icons --group-directories-first -T"
          alias tree "eza --icons --group-directories-first -T"
      end

      command -q bat; and alias cat "bat --paging=never"

      # ── Common ─────────────────────────────────────────────
      abbr -a c "clear"
      abbr -a h "history"
      abbr -a v "nvim"
      abbr -a e "nvim"
      abbr -a se "sudoedit"

      #? rm/trash - requires glib installed (Linux/Macos)
      abbr rmm "rm -rv"
      abbr rm "gio trash"
      abbr trl "gio trash --list"
      abbr trm "gio trash"
      abbr trs "gio trash --restore"

      # Source: https://www.baeldung.com/linux/delete-empty-files-dirs
      abbr rm-empty-files "find . -type f -empty -print -delete"
      abbr rm-empty-folders "find . -type d -empty -print -delete"

      # ── Git ────────────────────────────────────────────────
      abbr -a g "git"
      abbr -a ga "git add"
      abbr -a gaa "git add --all"
      abbr -a gb "git branch"
      abbr -a gca "git commit --amend"
      abbr -a gcl "git clone --depth 1"
      abbr -a gcm "git commit -m"
      abbr -a gco "git checkout"
      abbr -a gcp "git cherry-pick"
      abbr -a gcpa "git cherry-pick --abort"
      abbr -a gd "git diff"
      abbr -a gf "git fetch --all --prune"
      abbr -a gl "git pull"
      abbr -a glog "git log --oneline --graph --decorate --all"
      abbr -a gp "git push"
      abbr -a gpf "git push --force-with-lease"
      abbr -a gpsup "git push --set-upstream origin (git branch --show-current)"
      abbr -a grba "git rebase --abort"
      abbr -a grbc "git rebase --continue"
      abbr -a grbi "git rebase -i"
      abbr -a gs "git status"
      abbr -a gss "git status --short --branch"
      abbr -a gsw "git switch"
      abbr -a gst "git stash"
      abbr -a gstu "git stash push -u"
      abbr -a gstp "git stash pop"

      abbr -a lg lazygit

      if test (uname) = Linux
        # ── System ─────────────────────────────────────────────
        abbr -a jctl "journalctl -xeu"
        abbr -a ports "ss -tulpn"
        abbr -a path "printf '%s\n' $PATH"

        # ── Systemctl ──────────────────────────────────────────
        abbr -a sc "sudo systemctl"
        abbr -a scr "sudo systemctl restart"
        abbr -a sce "sudo systemctl enable"
        abbr -a scd "sudo systemctl disable"
        abbr -a scss "sudo systemctl status"
        abbr -a scst "sudo systemctl start"
        abbr -a scsp "sudo systemctl stop"

        abbr -a scu "systemctl --user"
        abbr -a scur "systemctl --user restart"
        abbr -a scue "systemctl --user enable"
        abbr -a scud "systemctl --user disable"
        abbr -a scuss "systemctl --user status"
        abbr -a scust "systemctl --user start"
        abbr -a scusp "systemctl --user stop"
      end

      # Check if using Arch-Based or Not
      if command -q pacman

      # Set Super User Command e.g. sudo | doas
      command -q doas && set PERMISSION_CMD doas || set PERMISSION_CMD sudo

      # Set AUR Helper
      command -q paru && set AUR_HELPER paru
      command -q yay && set AUR_HELPER yay

      if set -q AUR_HELPER; and command -q "$AUR_HELPER"
          abbr pmu "$AUR_HELPER -Syu"
          abbr pmi "$AUR_HELPER -S"
          abbr pms "$AUR_HELPER -Ss"

          abbr ppmu "$PERMISSION_CMD pacman -Syu"
          abbr ppmi "$PERMISSION_CMD pacman -S"
          abbr ppms "pacman -Ss"
      else
          abbr pmu "$PERMISSION_CMD pacman -Syu"
          abbr pmi "$PERMISSION_CMD pacman -S"
          abbr pms "pacman -Ss"
      end

      abbr pmq "pacman -Qi"
      abbr pmr "$PERMISSION_CMD pacman -Rns"
      abbr pmro "pacman -Qtdq | $PERMISSION_CMD pacman -Rns -"

      end

      if command -q brew

      abbr pmu "brew upgrade"
      abbr pmi "brew install"
      abbr pms "brew search"
      abbr pmq "brew info"
      abbr pmr "brew uninstall"
      abbr pmro "brew cleanup"
      end

      # Optional integration: importing Fish alone must not assume an editor or finder.
      if command -q nvim
          abbr -a e nvim
      else if command -q vim
          abbr -a e vim
      end
      if command -q nvim; and command -q fzf
          function nvim-fzf --description 'Choose a file and open it in Neovim'
              set -l preview 'cat -- {}'
              command -q bat; and set preview 'bat --style=numbers --color=always --line-range :500 {}'
              set -l file (fzf --reverse --height 80% --border --preview "$preview")
              test -n "$file"; or return 1
              nvim "$file"
          end
          abbr -a f nvim-fzf
          if command -q fd
              function nvim-config --description 'Choose an editable Neovim source file'
                  if not set -q DOTFILES_NVIM_SOURCE; or not test -d "$DOTFILES_NVIM_SOURCE"
                      echo 'Set DOTFILES_NVIM_SOURCE to the Neovim source directory in your checkout.' >&2
                      return 1
                  end
                  set -l file (fd --type f --follow . "$DOTFILES_NVIM_SOURCE" | fzf --reverse --height 80% --border)
                  test -n "$file"; or return 1
                  nvim "$file"
              end
              abbr -a nvimc nvim-config
          end
      end

      abbr yt "yt-dlp"

      # List all Format
      abbr ytf "yt-dlp --cookies-from-browser brave --list-formats"

      # Video
      set -l VIDEO_FLAG "--ignore-errors --continue --no-overwrites --embed-metadata --xattrs --embed-chapters --write-auto-subs --embed-subs --merge-output-format mkv -f \"bestvideo[vcodec^=av01][ext=mp4][height<=1080]+bestaudio[acodec^=opus]/bestvideo[vcodec^=vp9][ext=mp4][height<=1080]+bestaudio[acodec^=opus]/best\""

      abbr ytv "yt-dlp --output '%(title)s by %(uploader)s.%(ext)s' --no-playlist $VIDEO_FLAG"
      abbr ytp "yt-dlp -o '%(playlist_index)s %(title)s.%(ext)s' --download-archive 0-LIST.txt --yes-playlist $VIDEO_FLAG"

      # Music
      set -l MUSIC_FLAG "--ignore-errors --continue --no-overwrites --embed-metadata --embed-thumbnail --xattrs --extract-audio --audio-format best --audio-quality 0 -f bestaudio"

      abbr ytm "yt-dlp -o '%(title)s.%(ext)s' --no-playlist $MUSIC_FLAG"
      abbr ytmp "yt-dlp -o '%(title)s.%(ext)s' --download-archive 0-LIST.txt --yes-playlist $MUSIC_FLAG"

      # Secrets are supplied to individual applications by sops-nix runtime wrappers.
      # Example: hermes-with-secrets hermes. Interactive shells do not decrypt keys.

      # Preserve inherited agents, including SSH forwarding. NixOS's user service
      # owns this socket; portable shells never start an agent or guess desktop ones.
      if test -z "$SSH_AUTH_SOCK"; and test -n "$XDG_RUNTIME_DIR"
          if test -S "$XDG_RUNTIME_DIR/ssh-agent"
              set -gx SSH_AUTH_SOCK "$XDG_RUNTIME_DIR/ssh-agent"
          end
      end
    '';
    interactiveShellInit = ''
      set -g fish_greeting
      if command -q zoxide
        alias zz "z -"
        alias .. "z .."
        alias ... "z ../.."
        alias .... "z ../../.."
        abbr -a zl "z ~/Downloads/"
        abbr -a zd "z ~/Documents/"
      end
      bind \en down-or-search
      bind \ep up-or-search
      if test -f $__fish_config_dir/config.local.fish
          source $__fish_config_dir/config.local.fish
      end
    '';
    functions = {
      "ad" = {
        description = "Advanced file, better make new file";

        "body" = ''
          function mkfile
            set file $argv[1]
            switch $file
            case "*/"
              mkdir -p $file
            case "*"
              mkdir -p (dirname "$file")
              touch $file

            end
          end

          for file in $argv
            mkfile $file
          end
        '';
      };
      "backup" = {

        "body" = ''
          if test (count $argv) -eq 0
              echo "Usage: backup <file-or-directory>"
              return 1
          end

          set -l target $argv[1]

          if not test -e "$target"
              echo "Not found: $target"
              return 1
          end

          set -l timestamp (date +"%Y%m%d-%H%M%S")
          cp -a "$target" "$target.bak-$timestamp"
        '';
      };
      "compress-pdf" = {
        description = "Compress PDF using GhostScript";

        "body" = ''
          set file $argv[1]
          gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 \
              -dPDFSETTINGS=/ebook \
              -dNOPAUSE -dQUIET -dBATCH \
              -sOutputFile="$(string replace '.pdf' ''' $file)_compressed.pdf" \
              "$file"
        '';
      };
      "dev-health" = {
        description = "Show installed development tools";

        "body" = ''
          for tool in nvim git node bun php composer lerd adb java tinymist typst websocat
              if command -q $tool
                  command -s $tool
              else
                  printf 'missing: %s\n' $tool
              end
          end
        '';
      };
      "ff" = {

        "body" = ''
          # 1. Fix typo and set a safe default search term
          set -l query "."
          if set -q argv[1]
            set query $argv[1]
          end

          # 2. Feed fd directly to fzf to avoid memory overhead and allow streaming
          set -l file (fd --type f $query | fzf \
          --reverse \
          --height 80% \
          --border \
          --preview 'bat --style=numbers --color=always --line-range :500 {}' \
          --preview-window 'right:60%:wrap')

          # 3. Use standard string checking
          string length -q -- "$file"; or return 1

          # 4. Use bat instead of cat for consistent, beautiful output
          bat --color=always "$file"
          echo -e "\nSelected: $file"
        '';
      };
      "gclean-branches" = {

        "body" = ''
          git fetch --all --prune

          set -l branches (git branch -vv | awk '/: gone]/{print $1}')

          if test (count $branches) -eq 0
              echo "No gone branches."
              return 0
          end

          printf "%s\n" $branches
          read -l -P "Delete these branches? [y/N] " confirm

          if test "$confirm" = y
              git branch -D $branches
          else
              echo "Cancelled."
          end
        '';
      };
      "gclone" = {

        "body" = ''
          if test (count $argv) -eq 0
              echo "Usage: gclone <repo-url>"
              return 1
          end

          git clone $argv[1]
          and cd (basename $argv[1] .git)
        '';
      };
      "gignore" = {

        "body" = ''
          if test (count $argv) -eq 0
              echo "Usage: gignore <template>"
              echo "Example: gignore node"
              return 1
          end

          if test -L .gitignore; or test -d .gitignore
              echo "Refusing a symlink or directory .gitignore" >&2
              return 1
          end
          set -l temporary (${pkgs.coreutils}/bin/mktemp .gitignore.tmp.XXXXXXXX)
          or return 1
          set -l templates (string join , -- $argv)
          if curl -fsSL "https://www.toptal.com/developers/gitignore/api/$templates" > "$temporary"
              if test -f .gitignore
                  ${pkgs.coreutils}/bin/chmod --reference=.gitignore "$temporary"
                  or begin
                      ${pkgs.coreutils}/bin/rm -f -- "$temporary"
                      return 1
                  end
              end
              ${pkgs.coreutils}/bin/mv -T -- "$temporary" .gitignore
              set -l result $status
              ${pkgs.coreutils}/bin/rm -f -- "$temporary"
              return $result
          else
              set -l result $status
              ${pkgs.coreutils}/bin/rm -f -- "$temporary"
              return $result
          end
        '';
      };
      "groot" = {

        "body" = ''
          set -l root (git rev-parse --show-toplevel 2>/dev/null)

          if test -z "$root"
              echo "Not inside a Git repository."
              return 1
          end

          cd "$root"
        '';
      };
      "killport" = {

        "body" = ''
          if test (count $argv) -eq 0
              echo "Usage: killport <port>"
              return 1
          end

          set -l port $argv[1]
          set -l pids (lsof -ti tcp:$port)

          if test -z "$pids"
              echo "No process found on port $port"
              return 0
          end

          echo "Killing process on port $port: $pids"
          kill -9 $pids
        '';
      };
      "kssh" = {
        description = "ssh via kitty ssh kitten (terminfo + clipboard)";
        wraps = "ssh";

        "body" = "  kitten ssh $argv";
      };
      "path-clean" = {

        "body" = ''
          set -l clean_path

          for dir in $PATH
              if test -d "$dir"; and not contains "$dir" $clean_path
                  set clean_path $clean_path "$dir"
              end
          end

          set -gx PATH $clean_path
          printf "%s\n" $PATH
        '';
      };
      "path-show" = {

        "body" = ''
          for p in $PATH
              echo $p
          end
        '';
      };
      "reload" = {
        description = "Reload Fish configuration";

        "body" = ''
          source ~/.config/fish/config.fish
          echo "󰈐 Fish configuration reloaded!"
        '';
      };
      "serve" = {

        "body" = ''
          set -l port 8000

          if test (count $argv) -ge 1
              set port $argv[1]
          end

          if not command -q miniserve
              echo 'serve: miniserve belum tersedia; build dan apply konfigurasi Nix terlebih dahulu.' >&2
              return 127
          end
          command miniserve --port "$port" --index index.html --hidden --verbose -- .
        '';
      };
      "take" = {
        description = "Create a directory and enter it.";

        "body" = ''
          set folder $argv[1]
          mkdir -p $folder
          cd $folder
        '';
      };
      "todo" = {
        description = "Open TODO.md file";

        "body" = ''
          if not set -q EDITOR
              set EDITOR nvim
          end

          set todofile (if test -f "$PWD/TODO.md"; echo "$PWD/TODO.md"; else; echo "$HOME/TODO.md"; end)

          $EDITOR $todofile
        '';
      };
    };
  };
  xdg.configFile."fish/completions" = lib.mkIf config.programs.fish.enable {
    source = ./config/completions;
  };

}
