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
      go = {
        enable = true;
        format.type = [ "gofumpt" ];
      };
      rust.enable = true;
      python = {
        enable = true;
        format.type = [ "ruff" ];
      };
      clang.enable = true;
      php.enable = true;
      typescript.enable = true;
      tsx.enable = true;
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

    autocomplete.blink-cmp.enable = true;
    fzf-lua.enable = true;
    binds.whichKey.enable = true;
    formatter.conform-nvim.enable = true;
    diagnostics.nvim-lint.enable = true;

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
    };
  };
}
