# The single nvf configuration.
#
# Two consumers, one file: the Home Manager wrapper in
# `modules/home-manager/programs/cli/neovim.nix` imports it into
# `programs.nvf.settings`, and the standalone `package.nix` in this directory
# passes it to `nvf.lib.neovimConfiguration`, so the editor used by
# `nix run .#neovim` cannot drift from the installed one.
#
# Build-time behavior lives here and in `modules/` (options, maps, autocmds,
# commands). The live `runtime/` tree is native Neovim data only: after/
# overrides, queries, snippets and editor tool config.
#
# Curried: the outer arguments are ours (the runtime tree path and the Nerd Font
# switch), the inner ones are supplied by nvf's module system. The kernel takes
# `runtime` so the blink snippet source can read `<runtime>/snippets` directly
# instead of a parallel linkFarm - in live mode that makes snippets editable
# without a rebuild. `nerdFont` feeds both `vim.g.have_nerd_font` and every
# glyph-dependent setup below.
{
  runtime,
  nerdFont ? true,
  # "full" adds language servers, formatters and linters. "minimal" keeps the
  # editor self-contained: no toolchain beyond git/rg/fd/fzf, so it runs on any
  # host that only has Nix (`nix run github:atalariq/dotfiles#neovim`).
  profile ? "full",
}:
{ pkgs, lib, ... }:
let
  inherit (lib.generators) mkLuaInline;
  isFull = profile == "full";

  renderMarkdownOpts =
    lib.recursiveUpdate
      {
        enabled = true;
        preset = "none";
        render_modes = [
          "n"
          "c"
        ];
        anti_conceal.enabled = true;
        latex.enabled = false;
        nested = false;
        # The plugin has no public "default off per buffer" switch; its attach
        # hook runs before the first render, so flipping the buffer config here
        # keeps normal markdown raw while leaving preview buffers rendered.
        on.attach = mkLuaInline ''
          function(ctx)
            if vim.bo[ctx.buf].buftype == "" then
              require("render-markdown.state").get(ctx.buf).enabled = false
            end
          end
        '';
      }
      (
        lib.optionalAttrs (!nerdFont) {
          heading = {
            icons = [ ];
            signs = [ ];
            sign = false;
          };
          checkbox = {
            unchecked.icon = "[ ]";
            checked.icon = "[x]";
            custom.todo.rendered = "[ ]";
          };
          link.enabled = false;
          callout =
            lib.genAttrs
              [
                "note"
                "tip"
                "important"
                "warning"
                "caution"
                "abstract"
                "summary"
                "tldr"
                "info"
                "todo"
                "hint"
                "success"
                "check"
                "done"
                "question"
                "help"
                "faq"
                "attention"
                "failure"
                "fail"
                "missing"
                "danger"
                "error"
                "bug"
                "example"
                "quote"
                "cite"
              ]
              (name: {
                rendered = "[!${lib.toUpper name}]";
              });
        }
      );
in
{
  imports = [
    (import ./modules/core.nix { inherit nerdFont isFull; })
    (import ./modules/maps.nix)
    (import ./modules/commands.nix)
  ];

  vim = {
    # `vim` is a separate server editor on this machine, so the aliases stay off.
    viAlias = false;
    vimAlias = false;

    # blink-cmp-git registers a completion source module; it must be on the
    # packpath before blink.cmp is configured.
    startPlugins = [ pkgs.vimPlugins.blink-cmp-git ];

    # Tools the config shells out to: fzf-lua needs rg/fd/fzf, gitsigns needs
    # git, image and markdown helpers need curl/gzip. Minimal keeps only the
    # portable four; every other binary is a language-toolchain dependency.
    extraPackages =
      with pkgs;
      [
        git
        ripgrep
        fd
        fzf
      ]
      ++ lib.optionals isFull [
        curl
        gzip
        yamllint
        zoxide
        fish
      ]
      ++ lib.optionals (isFull && pkgs.stdenv.hostPlatform.isLinux) [
        wl-clipboard
      ];

    lsp = lib.mkIf isFull {
      enable = true;
      # Conform formats every save and falls back to LSP when no formatter is
      # configured. <leader>ltf toggles it per buffer; :FormatToggle flips the
      # global default.
      formatOnSave = true;
      mappings = {
        goToDefinition = "gd";
        codeAction = "<leader>ca";
        renameSymbol = "<leader>cr";
      };
      inlayHints.enable = false; # idempotent per-buffer branch lives in core.nix
      presets = {
        emmet-ls.enable = true;
        tailwindcss-language-server.enable = true;
      };
    };

    languages = lib.mkMerge [
      {
        enableTreesitter = true;
        enableFormat = isFull;
        enableExtraDiagnostics = isFull;
      }
      (lib.mkIf isFull {
        nix = {
          enable = true;
          lsp.servers = [ "nixd" ];
          format.type = [ "nixfmt" ];
        };
        lua = {
          enable = true;
          extraDiagnostics.types = [ "selene" ];
          extensions.lazydev.enable = true;
        };
        # Everything a host works in - heavy (node/tsx, python, go, rust, clang,
        # java, kotlin, dart) and gate-only (php, vue, svelte, sql, whose
        # runtimes stay per-project in containers or mise) - is driven by
        # `dotfiles.programs.development.stacks` and arrives from `langs.nix`; enabling any of
        # them here would defeat that gate.
        #
        # Everything below is baseline markup/config/shell tooling, useful on
        # every host regardless of declared stacks.
        html.enable = true;
        css.enable = true;
        scss.enable = true;
        markdown = {
          enable = true;
          format.type = [ "rumdl" ];
          extraDiagnostics.types = [ "rumdl" ];
        };
        typst.enable = true;
        tex.enable = true;
        fish.enable = true;
        bash.enable = true;
        zsh.enable = true;
        json.enable = true;
        yaml.enable = true;
        toml = {
          enable = true;
          lsp.servers = [ "tombi" ];
          format.type = [ "tombi" ];
          extraDiagnostics.types = [ "tombi" ];
        };
      })
    ];

    treesitter = {
      # Legacy nvim-ts-autotag parity for html.
      autotagHtml = true;
      # Native async treesitter folding (0.11+; this pin is 0.12).
      fold = true;
      # KDL is injected from #USAGE comments by the live after/queries tree.
      # Minimal adds the light, LSP-free parsers so a fresh host still gets
      # highlighting for the formats this repository is written in.
      grammars = [
        pkgs.tree-sitter-grammars.tree-sitter-kdl
      ]
      ++ lib.optionals (!isFull) (
        with pkgs.vimPlugins.nvim-treesitter.grammarPlugins;
        [
          markdown
          markdown_inline
          json
          yaml
          toml
          bash
          fish
          nix
          typst
        ]
      );
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
        appearance = lib.optionalAttrs nerdFont {
          nerd_font_variant = "mono";
        };
        completion = {
          ghost_text.enabled = true;
          documentation = {
            auto_show = true;
            auto_show_delay_ms = 200;
          };
        }
        // lib.optionalAttrs (!nerdFont) {
          menu.draw.columns = [
            [
              "label"
              "label_description"
            ]
          ];
        };
        signature.enabled = true;
        sources = {
          # lazydev and LSP only exist in the full profile; minimal still gets
          # git, path, snippet and buffer completion without any toolchain.
          default = lib.mkForce (
            [ "git" ]
            ++ lib.optionals isFull [
              "lazydev"
              "lsp"
            ]
            ++ [
              "path"
              "snippets"
              "buffer"
            ]
          );
          providers = {
            git = {
              module = "blink-cmp-git";
              name = "Git";
              opts = { };
            };
            snippets.opts = {
              friendly_snippets = true;
              search_paths = [ "${runtime}/snippets" ];
            };
          }
          // lib.optionalAttrs isFull {
            lazydev = {
              name = "LazyDev";
              module = "lazydev.integrations.blink";
              score_offset = 100;
            };
          };
        };
        cmdline = {
          keymap = {
            preset = "cmdline";
            "<CR>" = [
              "accept_and_enter"
              "fallback"
            ];
            "<Down>" = [
              "select_next"
              "fallback"
            ];
            "<Up>" = [
              "select_prev"
              "fallback"
            ];
          };
        };
      };
    };
    fzf-lua = {
      enable = true;
      profile = "borderless";
    };
    projects.project-nvim.enable = true;
    utility.outline.aerial-nvim = {
      enable = true;
      mappings.toggle = "<leader>o";
      setupOpts.nerd_font = nerdFont;
    };
    binds.whichKey.enable = true;
    formatter.conform-nvim = lib.mkIf isFull {
      enable = true;
      # nvf's presets predate the current CLI flags: nixfmt now needs an
      # explicit stdin marker, and tombi renamed --stdin-filepath to
      # --stdin-filename. Force the corrected argument lists so conform stops
      # writing formatter errors to ~/.local/state/nvf/conform.log.
      setupOpts.formatters = {
        nixfmt.args = lib.mkForce (
          lib.generators.mkLuaInline ''
            function(self, ctx)
              return { "--indent=" .. ctx.shiftwidth, "-" }
            end
          ''
        );
        tombi.args = lib.mkForce [
          "format"
          "--stdin-filename"
          "$FILENAME"
          "-"
        ];
      };
    };
    diagnostics.nvim-lint = lib.mkIf isFull {
      enable = true;
      linters_by_ft = {
        fish = [ "fish" ];
        yaml = [ "yamllint" ];
      };
      linters.selene.args = [
        "--config"
        "${runtime}/selene.toml"
      ];
    };
    utility.guess-indent-nvim.enable = true;

    # Label-jumping. `navigation.flash` does not exist in this nvf pin; the
    # real option is `utility.motion.flash-nvim` (nvf's spider module is absent
    # from this pin, so that add was dropped).
    utility.motion.flash-nvim.enable = true;

    git.gitsigns = {
      enable = true;
      mappings = {
        nextHunk = "]h";
        previousHunk = "[h";
      };
    };

    # vim-fugitive replaces lazygit for staging/:Git; Neogit is the structured
    # status/branch/commit UI. Both work with plain git, no external helper.
    git.vim-fugitive.enable = true;
    git.neogit.enable = true;

    # mini.surround replaces nvim-surround so the legacy sa/sd/sr maps stay.
    utility.surround.enable = false;
    mini.surround = {
      enable = true;
      setupOpts = {
        search_method = "cover_or_nearest";
        mappings = {
          add = "sa";
          delete = "sd";
          find = "sf";
          find_left = "sF";
          highlight = "sh";
          replace = "sr";
          suffix_last = "l";
          suffix_next = "n";
        };
      };
    };
    mini.ai = {
      enable = true;
      setupOpts = {
        n_lines = 500;
        mappings = {
          around_next = "aa";
          inside_next = "ii";
        };
      };
    };
    mini.align = {
      enable = true;
      setupOpts.mappings = {
        start = "ga";
        start_with_preview = "gA";
      };
    };
    mini.move.enable = true;
    mini.splitjoin.enable = true;
    mini.bracketed.enable = true;
    mini.bufremove.enable = true;
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
    mini.tabline = {
      enable = true;
      setupOpts.show_icons = nerdFont;
    };
    mini.icons = {
      enable = true;
      setupOpts.style = if nerdFont then "glyph" else "ascii";
    };
    autopairs.nvim-autopairs.enable = true;

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

    extraPlugins.dial = {
      package = pkgs.vimPlugins.dial-nvim;
      setup = ''
        local augend = require("dial.augend")
        require("dial.config").augends:register_group({
          default = {
            augend.integer.alias.decimal_int,
            augend.integer.alias.hex,
            augend.date.alias["%Y/%m/%d"],
            augend.date.alias["%Y-%m-%d"],
            augend.constant.alias.en_weekday,
            augend.constant.alias.en_weekday_full,
            augend.constant.alias.bool,
            augend.constant.alias.Bool,
            augend.semver.alias.semver,
          },
        })
      '';
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
        setupOpts = renderMarkdownOpts;
        # The plugin directory calls setup() once before lz.n applies our
        # options; that first pass can attach the current buffer with rendering
        # enabled. This second pass makes the initial view raw.
        after = ''
          if vim.bo.buftype == "" and vim.bo.filetype == "markdown" then
            require("render-markdown").buf_disable()
          end
        '';
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
        setupOpts = {
          default_file_explorer = true;
          delete_to_trash = true;
          columns = lib.optionals nerdFont [ "icon" ];
          view_options.show_hidden = true;
          keymaps = {
            "q" = "actions.close";
            "<C-t>" = "actions.select_tab";
            "<C-v>" = "actions.select_vsplit";
            "<C-s>" = "actions.select_split";
            "<BS>" = "actions.parent";
            "g." = "actions.toggle_hidden";
          };
        };
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
        setupModule = "img-clip";
        setupOpts = {
          default = {
            relative_to_current_file = true;
            dir_path = "assets";
            prompt_for_file_name = true;
            show_dir_path_in_prompt = true;
          };
          filetypes.typst.template = "#image(\"$FILE_PATH\")";
        };
      };
    };
  };
}
