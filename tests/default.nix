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
  umbrielSystem = systemWith { dotfiles.desktop.umbriel.enable = true; };
  greeterSystem = systemWith { dotfiles.desktop.greeter.enable = true; };
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
          dotfiles.deployment.checkout = "/tmp/dotfiles live checkout";
        }
      ];
    };
  immutableVim = vimWith "immutable";
  liveVim = vimWith "live";
  appearanceWith =
    extra:
    inputs.home-manager.lib.homeManagerConfiguration {
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
        extra
      ];
    };
  appearance = appearanceWith { };
  liveAppearance = appearanceWith { dotfiles.deployment.mode = "live"; };
  allowedLiveAppearance = appearanceWith {
    dotfiles.deployment.mode = "live";
    dotfiles.deployment.allowThemedFiles = true;
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
  secretsHome = inputs.home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    extraSpecialArgs = { inherit inputs; };
    modules = [
      ../modules/home-manager
      {
        home.username = "test";
        home.homeDirectory = "/home/test";
        home.stateVersion = "26.05";
        dotfiles.services.secrets.enable = true;
        dotfiles.services.secrets.applications.fixture.API_TOKEN = "FIXTURE_TOKEN";
        sops.secrets.FIXTURE_TOKEN.path = "/tmp/dotfiles-secret-test/token";
      }
    ];
  };
  secretWrapper = lib.findFirst (
    package: package.name == "fixture-with-secrets"
  ) (throw "Missing per-application secret wrapper") secretsHome.config.home.packages;
  mockRegisterRoot = pkgs.writeShellScript "mock-register-root" ''
    set -eu
    test "$1" = --realise
    test "$3" = --add-root
    test "$5" = --indirect
    ${pkgs.coreutils}/bin/ln -sfn "$2" "$4"
  '';
  mockedThemeHook =
    lib.replaceStrings [ "${pkgs.nix}/bin/nix-store" ] [ "${mockRegisterRoot}" ]
      appearance.config.home.activation.themeSelection.data;
  # Fail evaluation if the production seam changes instead of testing the real daemon.
  checkedThemeHook =
    assert lib.assertMsg (
      lib.hasInfix "mock-register-root" mockedThemeHook && !lib.hasInfix "nix-store" mockedThemeHook
    ) "Theme hook mock substitution failed; review the activation test seam.";
    mockedThemeHook;
  liveHelpers = import ../lib/configuration.nix {
    inherit lib pkgs;
    config = liveVim.config;
    checkout = "/tmp/dotfiles live checkout";
  };
  liveThemedHelpers = import ../lib/configuration.nix {
    inherit lib pkgs;
    config = allowedLiveAppearance.config;
    checkout = "/tmp/dotfiles live checkout";
  };
  foreignThemedSource = builtins.tryEval (
    builtins.deepSeq (liveThemedHelpers.themedSource (inputs.nixpkgs + "/README.md")) true
  );
  foreignThemedDirectory = builtins.tryEval (
    builtins.deepSeq (liveThemedHelpers.themedDirectory (inputs.nixpkgs + "/lib")) true
  );
  foreignLiveSource = builtins.tryEval (
    builtins.deepSeq (liveHelpers.source (inputs.nixpkgs + "/lib")) true
  );
  baseThemeHook = pkgs.writeShellScript "base-theme-hook" (
    ''
      set -euo pipefail
      newGenPath=$1
      run() { "$@"; }
    ''
    + checkedThemeHook
  );
  packagePaths = c: map toString c.config.home.packages;
in
builtins.removeAttrs
  {
    catalogue-inert =
      assert packagePaths empty == packagePaths baseline;
      assert empty.config.home.file == baseline.config.home.file;
      assert empty.config.systemd.user.services == baseline.config.systemd.user.services;
      pkgs.runCommand "catalogue-inert" { } "touch $out";
    system-features-independent =
      assert !emptySystem.config.services.keyd.enable;
      assert !emptySystem.config.programs.gpu-screen-recorder.enable;
      assert !emptySystem.config.programs.mango.enable;
      assert !emptySystem.config.programs.umbriel.enable;
      assert !emptySystem.config.services.greetd.enable;
      assert !umbrielSystem.config.services.pipewire.enable;
      assert !mangoSystem.config.services.greetd.enable;
      assert greeterSystem.config.services.greetd.enable;
      assert !greeterSystem.config.services.greetd.useTextGreeter;
      assert !emptySystem.config.programs.noctalia.enable;
      assert !emptySystem.config.virtualisation.podman.enable;
      assert !emptySystem.config.programs.steam.enable;
      assert !mangoSystem.config.services.espanso.enable;
      assert !mangoSystem.config.services.pipewire.enable;
      assert !mangoSystem.config.hardware.bluetooth.enable;
      assert !noctaliaSystem.config.hardware.bluetooth.enable;
      assert !noctaliaSystem.config.services.power-profiles-daemon.enable;
      pkgs.runCommand "system-features-independent" { } "touch $out";
    source-modes =
      assert !foreignLiveSource.success;
      assert !foreignThemedSource.success;
      assert !foreignThemedDirectory.success;
      assert !(builtins.tryEval liveAppearance.activationPackage.drvPath).success;
      assert lib.all (item: item.assertion) allowedLiveAppearance.config.assertions;
      assert lib.any (lib.hasInfix "themed files remain immutable") allowedLiveAppearance.config.warnings;
      pkgs.runCommand "source-modes" { } ''
        test "$(readlink ${
          liveVim.config.home.file.".vimrc".source
        })" = "/tmp/dotfiles live checkout/modules/home-manager/programs/vim/config/vimrc"
        cmp ${
          immutableVim.config.home.file.".vimrc".source
        } ${../modules/home-manager/programs/vim/config/vimrc}
        if bash ${pkgs.writeShellScript "check-live-checkout" liveVim.config.home.activation.checkDotfilesCheckout.data}; then
          echo "Accepted missing live checkout" >&2; exit 1
        fi
        mkdir -p '/tmp/dotfiles live checkout'
        bash ${pkgs.writeShellScript "check-live-checkout" liveVim.config.home.activation.checkDotfilesCheckout.data}
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
                ${../modules/home-manager/programs/capture/shot} ${../modules/home-manager/programs/capture/window} ${../modules/home-manager/programs/capture/record} ${../modules/home-manager/programs/capture/close} ${../modules/home-manager/programs/capture/pick-color} ${../lib/commands.sh} ${../lib/format.sh} ${./format.sh} ${../secrets/load.sh} ${./secrets.sh} ${../lib/audit-home.sh} ${./audit-locale.sh} ${../lib/cutover.sh} ${../lib/activate-owner.sh} ${./activate-owner.sh} \
                ${../devshell/bun-with-services/services} ${../modules/home-manager/appearance/theme-switch} ${./capture.sh} ${./desktop-workflow.sh} ${./shelf-native.sh} ${./capture-native.sh} ${./runtime.sh} ${./safety.sh} ${./cutover.sh} ${./shelf-stop.sh} ${./theme.sh} ${./containers.sh} ${./direnv.sh}
              while IFS= read -r -d "" file; do
            fish --no-config --no-execute "$file"
          done < <(find ${../modules/home-manager/programs/fish/config} -name '*.fish' -print0)
              touch "$out"
        '';
    desktop-bindings =
      let
        host = (import ../lib/hosts.nix { inherit inputs; }).nixosConfigurations.thinkpad-x13.config;
        home = host.home-manager.users.atalariq;
        shortcuts = import ../modules/home-manager/desktop/shortcuts.nix;
      in
      assert host.services.keyd.enable;
      assert home.dotfiles.desktop.umbriel.settings.general.mod_key == "Super";
      assert host.services.keyd.keyboards.superkey.settings.main.capslock == "overload(superkey, esc)";
      assert builtins.all (
        shortcut:
        let
          key = "Ctrl+Mod+Alt+${lib.optionalString shortcut.shift "Shift+"}${shortcut.key}";
        in
        home.dotfiles.desktop.umbriel.settings.keybinds.${key} == {
          action = "spawn:${shortcut.command}";
          repeat = false;
        }
      ) shortcuts;
      assert home.dotfiles.desktop.umbriel.settings.keybinds."Mod+Q".repeat == false;
      pkgs.runCommand "desktop-bindings"
        {
          nativeBuildInputs = [
            pkgs.gnugrep
            pkgs.keyd
          ];
        }
        ''
              ${lib.concatMapStringsSep "\n" (
                shortcut:
                "grep -Fx '${"bindn = CTRL+SUPER+ALT${lib.optionalString shortcut.shift "+SHIFT"},${shortcut.key},spawn,${shortcut.command}"}' ${
                  home.xdg.configFile."mango/binds.conf".source
                }"
              ) shortcuts}
              keyd check ${host.environment.etc."keyd/superkey.conf".source}
          test "$(tail -n ${toString (builtins.length shortcuts + 1)} ${
            home.xdg.configFile."mango/binds.conf".source
          } | head -n 1)" = 'key_mode = default'
            grep -Fx 'bindn = SUPER,q,spawn,desktop-close' ${home.xdg.configFile."mango/binds.conf".source}
              if grep -F XF86LaunchA ${home.xdg.configFile."mango/binds.conf".source}; then exit 1; fi
              touch "$out"
        '';
    audit-locale =
      pkgs.runCommand "audit-locale"
        {
          nativeBuildInputs = [
            pkgs.bash
            pkgs.coreutils
            pkgs.findutils
            pkgs.gnugrep
            pkgs.glibc.bin
          ];
          LOCALE_ARCHIVE = "${pkgs.glibcLocales}/lib/locale/locale-archive";
        }
        ''
          bash ${./audit-locale.sh} ${../lib/audit-home.sh}
          touch "$out"
        '';
    owner-activation =
      pkgs.runCommand "owner-activation"
        {
          nativeBuildInputs = [
            pkgs.bash
            pkgs.coreutils
            pkgs.jq
            pkgs.gnugrep
            pkgs.util-linux
            pkgs.gnused
          ];
        }
        ''
          bash ${./activate-owner.sh} ${../lib/activate-owner.sh}
          touch "$out"
        '';
    cutover =
      pkgs.runCommand "cutover"
        {
          nativeBuildInputs = [
            pkgs.bash
            pkgs.coreutils
            pkgs.findutils
            pkgs.jq
            pkgs.gnutar
            pkgs.util-linux
          ];
        }
        ''
          bash ${./cutover.sh} ${../.}
          touch "$out"
        '';
    shelf-stop =
      pkgs.runCommand "shelf-stop"
        {
          nativeBuildInputs = [
            pkgs.bash
            pkgs.coreutils
            pkgs.gawk
          ];
        }
        ''
          bash ${./shelf-stop.sh} ${../modules/home-manager/desktop/scripts/shelf-stop}
          touch "$out"
        '';
    safety-helpers =
      assert builtins.elem pkgs.glib shellHome.config.home.packages;
      pkgs.runCommand "safety-helpers"
        {
          nativeBuildInputs = [
            pkgs.bash
            pkgs.coreutils
            pkgs.findutils
            pkgs.gnugrep
            pkgs.fish
          ];
        }
        ''
          test -x ${pkgs.glib}/bin/gio
          bash ${./safety.sh} ${../lib/audit-home.sh} ${
            pkgs.writeText "gignore.fish" (
              "function gignore\n" + shellHome.config.programs.fish.functions.gignore.body + "\nend\n"
            )
          }
          touch "$out"
        '';
    format-discovery =
      pkgs.runCommand "format-discovery"
        {
          nativeBuildInputs = [
            pkgs.bash
            pkgs.coreutils
            pkgs.findutils
            pkgs.ripgrep
            pkgs.gnugrep
          ];
        }
        ''
          bash ${./format.sh} ${../lib/format.sh}
          touch "$out"
        '';
    secrets-loader =
      pkgs.runCommand "secrets-loader"
        {
          nativeBuildInputs = [
            pkgs.bash
            pkgs.coreutils
            pkgs.gnugrep
          ];
        }
        ''
          bash ${./secrets.sh} ${../secrets/load.sh} ${secretWrapper}/bin/fixture-with-secrets
          touch "$out"
        '';
    capture-workflow =
      pkgs.runCommand "capture-workflow"
        {
          nativeBuildInputs = [
            pkgs.bash
            pkgs.coreutils
            pkgs.findutils
            pkgs.gnugrep
            pkgs.jq
            pkgs.imagemagick
          ];
        }
        ''
          bash ${./capture.sh} ${../modules/home-manager/programs/capture}
          touch "$out"
        '';
    desktop-workflow =
      pkgs.runCommand "desktop-workflow"
        {
          nativeBuildInputs = [
            pkgs.bash
            pkgs.coreutils
            pkgs.jq
            pkgs.util-linux
            pkgs.gnugrep
          ];
        }
        ''
          bash ${./desktop-workflow.sh} ${../modules/home-manager/programs/capture}
          touch "$out"
        '';
    neovim-startup = pkgs.runCommand "neovim-startup" { nativeBuildInputs = [ editor ]; } ''
      export HOME="$TMPDIR/home"
      mkdir -p "$HOME"
      nvim --headless -i NONE -n '+lua local ok, err = pcall(require, "conform"); if not ok or vim.v.errmsg ~= "" then io.stderr:write(tostring(err) .. vim.v.errmsg); vim.cmd("cquit 1") end; assert(package.loaded["plugins.cmp"]); assert(package.loaded["plugins.debug"]); assert(vim.fn.exists(":PackInstall") == 0); for _, tool in ipairs({"gopls", "dlv", "basedpyright-langserver", "ruff", "clangd", "debugpy-adapter", "lldb-dap"}) do assert(vim.fn.executable(tool) == 1, tool) end' +qa >log 2>&1
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
  }
  (
    (lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
      "system-features-independent"
      "desktop-workflow"
      "cutover"
      "owner-activation"
      "audit-locale"
      "shelf-stop"
    ])
    ++ (lib.optionals (pkgs.stdenv.hostPlatform.system != "x86_64-linux") [ "desktop-bindings" ])
  )
