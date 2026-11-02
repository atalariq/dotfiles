# Global keymaps that are not owned by a plugin preset. Buffer-local LSP maps
# live in nvf's `vim.lsp.mappings`; ftplugin-specific maps stay in the live
# `after/ftplugin` tree.
{ lib, ... }:
let
  inherit (lib.generators) mkLuaInline;
  map = action: desc: {
    inherit action desc;
  };
  luaMap = action: desc: {
    action = mkLuaInline action;
    inherit desc;
  };
  cmd = command: desc: map "<cmd>${command}<cr>" desc;
  fzf = name: desc: cmd "FzfLua ${name}" desc;
in
{
  vim.maps = {
    insert = {
      "jk" = map "<Esc>" "Normal mode";
      "kj" = map "<Esc>" "Normal mode";
      "<C-s>" = map "<Esc><cmd>update<cr>" "Save";
    };

    normal = {
      # Search and navigation.
      "<leader><leader>" = fzf "buffers" "Buffers";
      "<leader>ff" = fzf "files" "Find files";
      "<leader>fg" = fzf "live_grep" "Live grep";
      "<leader>fw" = fzf "grep_cword" "Grep word under cursor";
      "<leader>fb" = fzf "buffers" "Buffers";
      "<leader>fh" = fzf "help_tags" "Help tags";
      "<leader>fk" = fzf "keymaps" "Keymaps";
      "<leader>fo" = fzf "oldfiles" "Old files";
      "<leader>fr" = fzf "resume" "Resume search";
      "<leader>fp" = fzf "builtin" "Search pickers";
      "<leader>ft" = fzf "tags_live_grep" "Tags";
      "<leader>fz" = fzf "zoxide" "Zoxide";
      "<leader>fd" = fzf "diagnostics_document" "Document diagnostics";
      "<leader>fD" = fzf "diagnostics_workspace" "Workspace diagnostics";
      "<leader>fq" = fzf "quickfix" "Quickfix";

      # Files and buffers.
      "<leader>e" = cmd "Oil" "File explorer";
      "<leader>E" =
        luaMap "function() vim.cmd.cd(vim.fn.expand('%:p:h')); vim.cmd.Oil() end" "File explorer here";
      "<leader>p" = cmd "PasteImage" "Paste image";
      "<leader>bn" = cmd "enew" "New buffer";
      "<leader>bv" = cmd "vsplit" "Vertical split";
      "<leader>w" = cmd "write" "Save";
      "<leader>q" = cmd "quit" "Quit";
      "<leader>x" = luaMap "function() require('quicker').toggle() end" "Toggle quickfix";
      "<leader>X" =
        luaMap "function() require('quicker').toggle({ loclist = true }) end" "Toggle loclist";
      "<leader>sr" = cmd "GrugFar" "Search and replace";
      "<leader>rr" = cmd "Review" "Review working tree";
      "<leader>rc" = cmd "Review commits" "Review commits";
      "<leader>rb" = cmd "Review branch" "Review branch";
      "<leader>rn" = cmd "Review note" "Review: note here";
      "<leader>re" = cmd "Review edit" "Review: edit comment";
      "<leader>rd" = cmd "Review delete" "Review: delete comment";
      "<leader>rx" = cmd "Review export" "Review: export";
      "<leader>ud" = cmd "Undotree" "Undo history";
      "<leader>ul" = luaMap ''
        function()
          local lines = vim.diagnostic.config().virtual_lines
          vim.diagnostic.config({ virtual_lines = not lines, virtual_text = lines })
        end
      '' "Toggle diagnostic virtual lines";

      # Movement and editing.
      "j" = {
        action = "v:count == 0 ? 'gj' : 'j'";
        expr = true;
        desc = "Down";
      };
      "k" = {
        action = "v:count == 0 ? 'gk' : 'k'";
        expr = true;
        desc = "Up";
      };
      "<C-h>" = map "<C-w>h" "Window left";
      "<C-j>" = map "<C-w>j" "Window down";
      "<C-k>" = map "<C-w>k" "Window up";
      "<C-l>" = map "<C-w>l" "Window right";
      "<C-u>" = map "<C-u>zz" "Half-page up, centered";
      "<C-d>" = map "<C-d>zz" "Half-page down, centered";
      "n" = map "nzzzv" "Next search, centered";
      "N" = map "Nzzzv" "Previous search, centered";
      "Y" = map "y$" "Yank to end of line";
      "J" = map "mzJ`z" "Join keeping cursor";
      "<Tab>" = cmd "bnext" "Next buffer";
      "<S-Tab>" = cmd "bprevious" "Previous buffer";
      "<C-s>" = cmd "update" "Save";
      "<leader>uw" = luaMap "function() vim.wo.wrap = not vim.wo.wrap end" "Toggle wrap";
      "<leader>cd" =
        luaMap "function() local root = vim.fs.root(0, { '.git', 'package.json', 'Cargo.toml', 'go.mod', 'pyproject.toml' }); vim.cmd.cd(root or vim.fn.expand('%:p:h')) end" "Cd to project root";

      # Git hunks.
      "<leader>hp" = cmd "Gitsigns preview_hunk_inline" "Preview hunk inline";
      "<leader>hB" = cmd "Gitsigns blame" "Blame buffer";

      # Dial.
      "<C-a>" = luaMap "function() require('dial.map').manipulate('increment', 'normal') end" "Increment";
      "<C-x>" = luaMap "function() require('dial.map').manipulate('decrement', 'normal') end" "Decrement";
      "g<C-a>" =
        luaMap "function() require('dial.map').manipulate('increment', 'gnormal') end" "Increment sequence";
      "g<C-x>" =
        luaMap "function() require('dial.map').manipulate('decrement', 'gnormal') end" "Decrement sequence";

      # Terminal.
      "<leader>tt" = cmd "ToggleTerm direction=horizontal" "Terminal horizontal";
      "<leader>tv" = cmd "ToggleTerm direction=vertical" "Terminal vertical";
      "<leader>tf" = cmd "ToggleTerm direction=float" "Terminal float";

      # Sessions.
      "<leader>ss" = luaMap ''
        function()
          local file = vim.fn.stdpath("state") .. "/session.vim"
          vim.cmd("mksession! " .. vim.fn.fnameescape(file))
          vim.notify("Session saved to " .. file)
        end
      '' "Save session";
      "<leader>sl" = luaMap ''
        function()
          local file = vim.fn.stdpath("state") .. "/session.vim"
          if vim.fn.filereadable(file) == 1 then
            vim.cmd("source " .. vim.fn.fnameescape(file))
            vim.notify("Session loaded")
          else
            vim.notify("No saved session yet", vim.log.levels.WARN)
          end
        end
      '' "Load session";

      # Buffer removal.
      "<A-q>" = luaMap "function() require('mini.bufremove').delete() end" "Close buffer";
      "<A-Q>" = luaMap "function() require('mini.bufremove').delete(0, true) end" "Force close buffer";
    };

    visualOnly = {
      "<" = map "<gv" "Indent left";
      ">" = map ">gv" "Indent right";
      "<C-a>" = luaMap "function() require('dial.map').manipulate('increment', 'visual') end" "Increment";
      "<C-x>" = luaMap "function() require('dial.map').manipulate('decrement', 'visual') end" "Decrement";
      "g<C-a>" =
        luaMap "function() require('dial.map').manipulate('increment', 'gvisual') end" "Increment sequence";
      "g<C-x>" =
        luaMap "function() require('dial.map').manipulate('decrement', 'gvisual') end" "Decrement sequence";
    };
  };
}
