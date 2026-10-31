# The single nvf configuration.
#
# Two consumers, one file: Home Manager imports it into `programs.nvf.settings`,
# and the standalone package passes it to `nvf.lib.neovimConfiguration`, so the
# editor used by `nix run .#neovim` cannot drift from the installed one.
#
# Everything here is build time: plugins, LSP servers, formatters, parsers.
# Runtime behaviour (keymaps, autocmds, the live `after/` tree) lives in
# `runtime/` and is injected by `runtime-layer.nix`.
{ pkgs, lib, ... }:
{
  vim = {
    # `vim` is a separate server editor on this machine, so the aliases stay off.
    viAlias = false;
    vimAlias = false;

    # Tools the config shells out to: fzf-lua needs rg/fd/fzf, gitsigns needs
    # git, image and markdown helpers need curl/gzip.
    extraPackages =
      with pkgs;
      [
        git
        ripgrep
        fd
        fzf
        curl
        gzip
      ]
      ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
        wl-clipboard
      ];

    lsp = {
      enable = true;
      # Formatting is on demand (`<leader>lf` / `<leader>ltf`): a review-oriented
      # editor must not rewrite a file just because it was opened and saved.
      formatOnSave = false;
    };

    languages = {
      enableTreesitter = true;
      enableFormat = true;
      enableExtraDiagnostics = true;

      nix = {
        enable = true;
        lsp.servers = [ "nixd" ];
        format.type = [ "nixfmt" ];
      };
      lua = {
        enable = true;
        extraDiagnostics.types = [ "selene" ];
      };
      # Heavy language toolchains (node/tsx, python, go, rust, clang, java,
      # kotlin, dart) are host-gated through `dotfiles.dev.stacks` and arrive
      # from `stacks-langs.nix`; enabling them here would defeat that gate.
      #
      # Everything below is EDITOR-ONLY (owner decision 2026-10-31): nvf bundles
      # its LSP/formatter tooling inside the nvim wrapper, so these languages
      # never add PATH toolchains — runtimes stay per-project via mise or
      # docker compose.
      php.enable = true; # Laravel work; runtime lives in containers (Sail/compose)
      sql.enable = true; # coursework/DB work; clients likewise per-project
      vue.enable = true; # Vue3 frontend work
      html.enable = true;
      css.enable = true;
      scss.enable = true;
      markdown = {
        enable = true;
        format.type = [ "prettier" ];
      };
      typst.enable = true;
      tex.enable = true;
      fish.enable = true;
      bash.enable = true;
      zsh.enable = true;
      json.enable = true;
      yaml.enable = true;
      toml.enable = true;
    };

    treesitter = {
      # Legacy nvim-ts-autotag parity for html.
      autotagHtml = true;
      # Native async treesitter folding (0.11+; this pin is 0.12).
      fold = true;
    };

    autocomplete.blink-cmp = {
      enable = true;
      friendly-snippets.enable = true;
      # nvf's default injects a select_next/snippet_forward Tab chain; the
      # owner's legacy behavior is blink's own super-tab preset. Null the
      # injected maps so the preset survives (blink merges explicit maps over
      # presets).
      mappings.next = null;
      mappings.previous = null;
      setupOpts = {
        keymap = {
          preset = "super-tab";
        };
        sources.providers.snippets.opts = {
          friendly_snippets = true;
          search_paths = [
            (
              pkgs.linkFarm "dotfiles-nvim-snippets" [
                {
                  name = "snippets";
                  path = ./snippets;
                }
              ]
              + "/snippets"
            )
          ];
        };
      };
    };
    fzf-lua.enable = true;
    binds.whichKey.enable = true;
    formatter.conform-nvim.enable = true;
    diagnostics.nvim-lint.enable = true;

    # Label-jumping. `navigation.flash` does not exist in this nvf pin; the
    # real option is `utility.motion.flash-nvim` (nvf's spider module is absent
    # from this pin, so that add was dropped).
    utility.motion.flash-nvim.enable = true;

    # DAP: adapters only, no UI preset (dap-view is lazy-loaded below). The Go
    # adapter stays host-gated in stacks-langs.nix.
    debugger.nvim-dap = {
      enable = true;
      presets = {
        codelldb.enable = true;
        debugpy.enable = true;
      };
    };

    git.gitsigns.enable = true;

    utility.surround.enable = true;
    terminal.toggleterm.enable = true;

    navigation.harpoon = {
      enable = true;
      # nvf defaults claim <C-e>/<C-j>/<C-k>/<C-l>/<C-;>, which are window and
      # cursor keys; keep harpoon inside its own leader namespace.
      mappings = {
        markFile = "<leader>ha";
        listMarks = "<leader>hl";
        file1 = "<leader>h1";
        file2 = "<leader>h2";
        file3 = "<leader>h3";
        file4 = "<leader>h4";
      };
    };

    # ── Visuals ────────────────────────────────────────────────────────────
    # mini.* inherits the standard highlight groups, so Stylix colours it with
    # no extra theme glue.
    mini.statusline.enable = true;
    mini.tabline.enable = true;
    visuals.nvim-web-devicons.enable = true;
    visuals.indent-blankline = {
      enable = true;
      setupOpts = {
        scope = {
          show_start = false;
          show_end = false;
        };
      };
    };
    visuals.rainbow-delimiters.enable = true;
    visuals.fidget-nvim = {
      enable = true;
      setupOpts = {
        progress = {
          display = {
            done_icon = " ";
          };
        };
        notification = {
          # LSP progress only; never let a completed task steal a notification.
          override_vim_notify = false;
        };
      };
    };
    autopairs.nvim-autopairs.enable = true;
    ui.colorizer.enable = true;

    # undotree ships only `plugin/undotree.vim`, and lz.n sources `.lua` plugin
    # files, so lazy-loading it would leave `:Undotree` undefined. It is small
    # enough to stay a start plugin.
    startPlugins = [ pkgs.vimPlugins.undotree ];

    # Spell dictionaries as a data-only plugin: compiled `.spl` files on the
    # runtimepath are what Neovim reads (hunspell sources are not accepted).
    extraPlugins.dotfiles-spell = {
      package = pkgs.vimUtils.buildVimPlugin {
        pname = "dotfiles-spell";
        version = "2026-10-31";
        src = pkgs.linkFarm "dotfiles-spell" [
          {
            name = "spell/en.utf-8.spl";
            path = pkgs.fetchurl {
              url = "https://ftp.nluug.nl/pub/vim/runtime/spell/en.utf-8.spl";
              sha256 = "0w1h9lw2c52is553r8yh5qzyc9dbbraa57w9q0r9v8xn974vvjpy";
            };
          }
          {
            name = "spell/id.utf-8.spl";
            path = pkgs.fetchurl {
              url = "https://ftp.nluug.nl/pub/vim/runtime/spell/id.utf-8.spl";
              sha256 = "0jzb0lj2zvijh340j0vnxxnicrqq48fmxg9ra8qnynd08wn4kmki";
            };
          }
        ];
      };
      setup = ""; # data-only plugin
    };

    # ── Lazy loading ───────────────────────────────────────────────────────
    # Heavy or occasional plugins load on their trigger instead of at startup.
    # Keys must match the package pname, which is what lz.n resolves against.
    lazy.plugins = {
      "render-markdown.nvim" = {
        package = pkgs.vimPlugins.render-markdown-nvim;
        # Markdown is read raw first; rendering is a deliberate action.
        ft = "markdown";
        setupModule = "render-markdown";
        setupOpts.enabled = false;
      };
      "hunk.nvim" = {
        package = pkgs.vimPlugins.hunk-nvim;
        cmd = [
          "HunkDiffView"
          "HunkDiffEditor"
        ];
      };
      "oil.nvim" = {
        package = pkgs.vimPlugins.oil-nvim;
        cmd = "Oil";
        # oil only creates the `:Oil` command inside setup(), so lz.n's stub
        # command is not enough on its own.
        setupModule = "oil";
        setupOpts = { };
      };
      "grug-far.nvim" = {
        package = pkgs.vimPlugins.grug-far-nvim;
        cmd = "GrugFar";
      };
      "quicker.nvim" = {
        package = pkgs.vimPlugins.quicker-nvim;
        # quicker has no command at all - it registers its quickfix behaviour
        # from setup() - so there is nothing to lazy-load on.
        lazy = false;
        setupModule = "quicker";
        setupOpts = { };
      };
      "img-clip.nvim" = {
        package = pkgs.vimPlugins.img-clip-nvim;
        cmd = "PasteImage";
      };
      "nvim-dap-view" = {
        package = pkgs.vimPlugins.nvim-dap-view;
        cmd = [
          "DapViewOpen"
          "DapViewToggle"
        ];
        setupModule = "dap-view";
        setupOpts = { };
      };
    };
  };
}
