{
  inputs,
  pkgs,
  editor,
}:
let
  lib = pkgs.lib;
  empty = inputs.home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    extraSpecialArgs = { inherit inputs; };
    modules = [
      ../modules/home-manager
      {
        home.username = "test";
        home.homeDirectory = "/home/test";
        home.stateVersion = "26.05";
      }
    ];
  };
  # Compare with HM itself, not a brittle assertion about an empty package list:
  # Home Manager may legitimately include its own support packages.
  baseline = inputs.home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    modules = [
      {
        home.username = "test";
        home.homeDirectory = "/home/test";
        home.stateVersion = "26.05";
      }
    ];
  };
  systemWith =
    extra:
    inputs.nixpkgs.lib.nixosSystem {
      system = pkgs.stdenv.hostPlatform.system;
      specialArgs = { inherit inputs; };
      modules = [
        ../modules/nixos
        { system.stateVersion = "26.05"; }
        extra
      ];
    };
  emptySystem = systemWith { };
  noctaliaSystem = systemWith { dotfiles.desktop.noctalia.enable = true; };
  mangoSystem = systemWith { dotfiles.desktop.mango.enable = true; };
  vimWith =
    mode:
    inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = { inherit inputs; };
      modules = [
        ../modules/home-manager
        {
          home.username = "test";
          home.homeDirectory = "/home/test";
          home.stateVersion = "26.05";
          dotfiles.programs.vim.enable = true;
          dotfiles.deployment.mode = mode;
          dotfiles.deployment.checkout = "/home/test/source checkout";
        }
      ];
    };
  immutableVim = vimWith "immutable";
  liveVim = vimWith "live";
  appearance = inputs.home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    extraSpecialArgs = {
      inherit inputs;
      neovimPackage = editor;
    };
    modules = [
      ../modules/home-manager
      {
        home.username = "test";
        home.homeDirectory = "/build/theme-home";
        home.stateVersion = "26.05";
        dotfiles = {
          appearance.enable = true;
          programs.btop.enable = true;
          programs.bat.enable = true;
          programs.neovim.enable = true;
          programs.vim.enable = true;
        };
        programs = {
          yazi.enable = true;
          bash.enable = true;
          fish.enable = true;
          direnv.enable = true;
        };
      }
    ];
  };
  shellHome = inputs.home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    extraSpecialArgs = { inherit inputs; };
    modules = [
      ../modules/home-manager
      {
        home.username = "test";
        home.homeDirectory = "/build/shell-home";
        home.stateVersion = "26.05";
        programs.fish.enable = true;
        programs.yazi.enable = true;
        programs.atuin.enable = true;
        programs.television.enable = true;
      }
    ];
  };
  mockRegisterRoot = pkgs.writeShellScript "mock-register-root" ''
    set -eu
    test "$1" = --realise
    test "$3" = --add-root
    test "$5" = --indirect
    ${pkgs.coreutils}/bin/ln -sfn "$2" "$4"
  '';
  baseThemeHook = pkgs.writeShellScript "base-theme-hook" (
    ''
      set -euo pipefail
      newGenPath=$1
      run() { "$@"; }
    ''
    +
      lib.replaceStrings [ "${pkgs.nix}/bin/nix-store" ] [ "${mockRegisterRoot}" ]
        appearance.config.home.activation.themeSelection.data
  );
  packagePaths = c: map toString c.config.home.packages;
in
builtins.removeAttrs {
  catalogue-inert =
    assert packagePaths empty == packagePaths baseline;
    assert empty.config.home.file == baseline.config.home.file;
    assert empty.config.systemd.user.services == baseline.config.systemd.user.services;
    pkgs.runCommand "catalogue-inert" { } "touch $out";
  system-features-independent =
    assert !emptySystem.config.programs.mango.enable;
    assert !emptySystem.config.programs.noctalia.enable;
    assert !emptySystem.config.virtualisation.podman.enable;
    assert !emptySystem.config.programs.steam.enable;
    assert !mangoSystem.config.services.espanso.enable;
    assert !mangoSystem.config.services.pipewire.enable;
    assert !mangoSystem.config.hardware.bluetooth.enable;
    assert !noctaliaSystem.config.hardware.bluetooth.enable;
    assert !noctaliaSystem.config.services.power-profiles-daemon.enable;
    pkgs.runCommand "system-features-independent" { } "touch $out";
  source-modes = pkgs.runCommand "source-modes" { } ''
    test "$(readlink ${
      liveVim.config.home.file.".vimrc".source
    })" = "/home/test/source checkout/modules/home-manager/programs/vim/config/vimrc"
    cmp ${
      immutableVim.config.home.file.".vimrc".source
    } ${../modules/home-manager/programs/vim/config/vimrc}
    touch "$out"
  '';
  direnv-gating =
    assert !empty.config.programs.direnv.enable;
    assert
      lib.length (lib.splitString "direnv hook fish" appearance.config.programs.fish.interactiveShellInit)
      == 2;
    assert
      lib.length (lib.splitString "direnv hook bash" appearance.config.programs.bash.initExtra) == 2;
    pkgs.runCommand "direnv-gating" { } "touch $out";
  theme-switching =
    assert
      packagePaths appearance
      == map toString appearance.config.specialisation.gruvbox-dark.configuration.home.packages;
    assert
      packagePaths appearance
      == map toString appearance.config.specialisation.gruvbox-light.configuration.home.packages;
    pkgs.runCommand "theme-switching"
      {
        nativeBuildInputs = [
          pkgs.bash
          pkgs.coreutils
          pkgs.jq
          pkgs.util-linux
          pkgs.gnused
        ];
      }
      ''
        bash ${./theme.sh} ${../modules/home-manager/appearance/theme-switch} ${baseThemeHook}
        touch "$out"
      '';
  commands =
    pkgs.runCommand "command-routing"
      {
        nativeBuildInputs = [
          pkgs.bash
          pkgs.jq
          pkgs.gnugrep
          pkgs.coreutils
        ];
      }
      ''
        bash ${./commands.sh} ${../.}
        touch "$out"
      '';
  fish-startup =
    assert
      shellHome.config.programs.yazi.initLua
      == builtins.readFile ../modules/home-manager/programs/yazi/config/init.lua;
    pkgs.runCommand "fish-startup"
      {
        nativeBuildInputs = [
          pkgs.fish
          pkgs.coreutils
        ];
      }
      ''
        export HOME="$TMPDIR/home"
        export XDG_CONFIG_HOME="$HOME/.config"
        export __HM_SESS_VARS_SOURCED=1
        mkdir -p "$HOME" "$TMPDIR/bin" "$TMPDIR/destination"
        cat > "$TMPDIR/bin/yazi" <<'MOCK'
        #!${pkgs.runtimeShell}
        for argument do
          case "$argument" in --cwd-file=*) printf '%s\n' "$YAZI_TEST_DESTINATION" > "''${argument#--cwd-file=}";; esac
        done
        MOCK
        chmod +x "$TMPDIR/bin/yazi"
        export PATH="$TMPDIR/bin:$PATH"
        export YAZI_TEST_DESTINATION="$TMPDIR/destination"
        ${pkgs.fish}/bin/fish --no-config --no-execute ${
          shellHome.config.xdg.configFile."fish/config.fish".source
        }
        ${pkgs.fish}/bin/fish --no-config --interactive --command '
          set -g fish_key_bindings fish_default_key_bindings
          source ${shellHome.config.xdg.configFile."fish/config.fish".source}
          string match -q "*_atuin_search*" -- (bind ctrl-r); or exit 1
          string match -q "*tv_smart_autocomplete*" -- (bind ctrl-t); or exit 1
          if bind --user c,r >/dev/null 2>&1; exit 1; end
          abbr --query yt; or exit 1
          abbr --query yy; or exit 1
          functions --query yazicd; or exit 1
          yazicd
          test "$PWD" = "$YAZI_TEST_DESTINATION"; or exit 1
        '
        touch "$out"
      '';
  runtime-helpers =
    pkgs.runCommand "runtime-helpers"
      {
        nativeBuildInputs = with pkgs; [
          bash
          coreutils
          util-linux
          gnugrep
          findutils
          git
        ];
      }
      ''
        bash ${./runtime.sh} ${../.}
        touch "$out"
      '';
  shell-syntax =
    pkgs.runCommand "shell-syntax"
      {
        nativeBuildInputs = [
          pkgs.shellcheck
          pkgs.fish
        ];
      }
      ''
            shellcheck \
              ${../modules/home-manager/desktop/scripts}/* \
              ${../modules/home-manager/programs/_terminal-scripts}/* \
              ${../modules/home-manager/programs/_media-scripts}/* \
              ${../modules/home-manager/programs/_security-scripts}/* \
              ${../modules/home-manager/desktop/mango/config/script}/* ${../lib/commands.sh} \
              ${../devshell/bun-with-services/services} ${../modules/home-manager/appearance/theme-switch} ${./runtime.sh} ${./theme.sh} ${./containers.sh} ${./direnv.sh}
            while IFS= read -r -d "" file; do
          fish --no-config --no-execute "$file"
        done < <(find ${../modules/home-manager/programs/fish/config} -name '*.fish' -print0)
            touch "$out"
      '';
  neovim-startup = pkgs.runCommand "neovim-startup" { nativeBuildInputs = [ editor ]; } ''
    export HOME="$TMPDIR/home"
    mkdir -p "$HOME"
    nvim --headless -i NONE -n '+lua assert(package.loaded["plugins.cmp"]); assert(package.loaded["plugins.debug"]); assert(vim.fn.exists(":PackInstall") == 0); for _, tool in ipairs({"gopls", "dlv", "basedpyright-langserver", "ruff", "clangd", "debugpy-adapter", "lldb-dap"}) do assert(vim.fn.executable(tool) == 1, tool) end' +qa >log 2>&1
    cat log
    if grep -E 'Error detected|E[0-9]+:|stack traceback' log; then exit 1; fi
    touch "$out"
  '';
  vim-server = pkgs.runCommand "vim-server" { nativeBuildInputs = [ pkgs.vim ]; } ''
    export HOME="$TMPDIR/home"
    mkdir -p "$HOME"
    vim -N -n -es -i NONE -u ${../modules/home-manager/programs/vim/config/vimrc} \
      '+call assert_equal(1, &number)' '+call assert_equal(1, &hidden)' \
      '+if len(v:errors) | cquit | endif' +qa
    touch "$out"
  '';
} (lib.optionals pkgs.stdenv.hostPlatform.isDarwin [ "system-features-independent" ])
