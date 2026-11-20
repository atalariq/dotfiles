# Core Neovim state: globals, options, diagnostics and the editor-wide
# autocommands. This is build-time configuration; ftplugin/query/snippet files
# stay in the live runtime tree because they are native Neovim data.
{ nerdFont, isFull }:
{ lib, ... }:
let
  inherit (lib.generators) mkLuaInline;
  diagnosticSigns =
    if nerdFont then
      ''
        {
          [vim.diagnostic.severity.ERROR] = "󰅚 ",
          [vim.diagnostic.severity.WARN] = "󰀪 ",
          [vim.diagnostic.severity.INFO] = "󰋽 ",
          [vim.diagnostic.severity.HINT] = "󰌵 ",
        }
      ''
    else
      ''
        {
          [vim.diagnostic.severity.ERROR] = "E ",
          [vim.diagnostic.severity.WARN] = "W ",
          [vim.diagnostic.severity.INFO] = "I ",
          [vim.diagnostic.severity.HINT] = "H ",
        }
      '';
in
{
  vim = {
    globals = {
      mapleader = " ";
      maplocalleader = "\\";
      have_nerd_font = nerdFont;
    };

    # nvf owns the option surface; these are the values that are not covered
    # by nvf's own defaults.
    preventJunkFiles = true;
    hideSearchHighlight = true;
    searchCase = "smart";
    lineNumberMode = "relNumber";
    undoFile.enable = true;

    options = {
      clipboard = "unnamedplus";
      mouse = "a";
      smoothscroll = true;
      updatetime = 250;
      timeoutlen = 300;
      signcolumn = "yes";
      cursorline = true;
      tabstop = 2;
      shiftwidth = 2;
      expandtab = true;
      smartindent = true;
      breakindent = true;
      linebreak = true;
      list = true;
      listchars = {
        tab = "» ";
        trail = "·";
        nbsp = "␣";
      };
      wrap = false;
      showmode = false;
      scrolloff = 8;
      sidescrolloff = 8;
      foldlevel = 99;
      foldlevelstart = 99;
      sessionoptions = "buffers,curdir,folds,tabpages,winsize";
      pumheight = 10;
      completeopt = "menu,menuone,noselect";
      splitbelow = true;
      splitright = true;
      virtualedit = "block";
      winborder = "rounded";
      spelllang = "en_us,id";
      # conform only exists in the full profile; a missing require would break
      # `gq` on the minimal editor.
      formatexpr = lib.mkIf isFull "v:lua.require'conform'.formatexpr()";
    };

    diagnostics = {
      enable = true;
      config = {
        signs = {
          text = mkLuaInline diagnosticSigns;
        };
        virtual_text = true;
        update_in_insert = false;
      };
    };

    augroups = [
      { name = "dotfiles"; }
      { name = "dotfiles_lsp"; }
    ];

    autocmds = [
      {
        group = "dotfiles";
        event = [ "BufWritePre" ];
        desc = "Trim trailing whitespace on code buffers";
        callback = mkLuaInline ''
          function()
            local ft = vim.bo.filetype
            if ft == "markdown" or ft == "typst" or ft == "text" then
              return
            end
            local save = vim.fn.getpos(".")
            vim.cmd([[%s/\s\+$//e]])
            vim.fn.setpos(".", save)
          end
        '';
      }
      {
        group = "dotfiles";
        event = [
          "FocusGained"
          "TermClose"
          "TermLeave"
        ];
        desc = "Reload files changed on disk";
        callback = mkLuaInline ''
          function()
            if vim.o.buftype ~= "nofile" then
              vim.cmd("checktime")
            end
          end
        '';
      }
      {
        group = "dotfiles";
        event = [ "VimResized" ];
        desc = "Equalize splits after a resize";
        callback = mkLuaInline ''
          function()
            local tab = vim.fn.tabpagenr()
            vim.cmd("tabdo wincmd =")
            vim.cmd("tabnext " .. tab)
          end
        '';
      }
      {
        group = "dotfiles";
        event = [ "BufReadPost" ];
        desc = "Restore the last cursor position";
        callback = mkLuaInline ''
          function(ev)
            if vim.tbl_contains({ "gitcommit" }, vim.bo[ev.buf].filetype) then
              return
            end
            local mark = vim.api.nvim_buf_get_mark(ev.buf, '"')
            local count = vim.api.nvim_buf_line_count(ev.buf)
            if mark[1] > 0 and mark[1] <= count then
              pcall(vim.api.nvim_win_set_cursor, 0, mark)
            end
          end
        '';
      }
      {
        group = "dotfiles";
        event = [ "FileType" ];
        pattern = [
          "PlenaryTestPopup"
          "checkhealth"
          "dbout"
          "gitsigns-blame"
          "grug-far"
          "help"
          "lspinfo"
          "notify"
          "qf"
          "startuptime"
          "tsplayground"
        ];
        desc = "Close transient buffers with q";
        callback = mkLuaInline ''
          function(ev)
            vim.bo[ev.buf].buflisted = false
            vim.schedule(function()
              vim.keymap.set("n", "q", function()
                vim.cmd("close")
                pcall(vim.api.nvim_buf_delete, ev.buf, { force = true })
              end, { buffer = ev.buf, silent = true, desc = "Quit buffer" })
            end)
          end
        '';
      }
      {
        group = "dotfiles";
        event = [ "BufWritePre" ];
        desc = "Create missing parent directories";
        callback = mkLuaInline ''
          function(ev)
            if ev.match:match("^%w%w+:[\\/][\\/]") then
              return
            end
            local file = vim.uv.fs_realpath(ev.match) or ev.match
            vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
          end
        '';
      }
      {
        group = "dotfiles";
        event = [ "FileType" ];
        pattern = [ "man" ];
        desc = "Keep man buffers unlisted";
        callback = mkLuaInline ''
          function(ev)
            vim.bo[ev.buf].buflisted = false
          end
        '';
      }
      {
        group = "dotfiles";
        event = [ "FileType" ];
        pattern = [
          "json"
          "jsonc"
          "json5"
        ];
        desc = "Do not conceal JSON";
        callback = mkLuaInline ''
          function()
            vim.opt_local.conceallevel = 0
          end
        '';
      }
      {
        group = "dotfiles";
        event = [ "FileType" ];
        pattern = [
          "text"
          "plaintex"
          "typst"
          "gitcommit"
          "markdown"
        ];
        desc = "Enable Indonesian and English spell checking for prose";
        callback = mkLuaInline ''
          function()
            vim.opt_local.spell = true
            vim.opt_local.spelllang = { "id", "en" }
          end
        '';
      }
      {
        group = "dotfiles";
        event = [ "FileType" ];
        desc = "Do not continue comments on o/O";
        callback = mkLuaInline ''
          function()
            vim.bo.formatoptions = vim.bo.formatoptions:gsub("[cr]", "")
          end
        '';
      }
      {
        group = "dotfiles";
        event = [ "TextYankPost" ];
        desc = "Highlight the yanked region";
        callback = mkLuaInline ''
          function()
            vim.highlight.on_yank({ timeout = 150 })
          end
        '';
      }
      {
        group = "dotfiles";
        event = [ "FileChangedShellPost" ];
        desc = "Notify when a buffer was reloaded";
        callback = mkLuaInline ''
          function()
            vim.notify("File changed on disk; buffer reloaded", vim.log.levels.WARN)
          end
        '';
      }
      {
        group = "dotfiles_lsp";
        event = [ "LspAttach" ];
        desc = "Enable inlay hints once per buffer and keep the toggle idempotent";
        callback = mkLuaInline ''
          function(ev)
            local client = ev.data and vim.lsp.get_client_by_id(ev.data.client_id)
            if client and client:supports_method("textDocument/inlayHint") and vim.b[ev.buf].dotfiles_inlay == nil then
              vim.b[ev.buf].dotfiles_inlay = true
              vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
            end
          end
        '';
      }
    ];

    luaConfigRC.dotfilesSpell = ''
      vim.fn.mkdir(vim.fn.stdpath("data") .. "/spell", "p")
      vim.o.spellfile = vim.fn.stdpath("data") .. "/spell/en.utf-8.add"
    '';
  };
}
