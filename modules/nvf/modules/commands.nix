# Small Lua glue that cannot be expressed as a mapping or an option.
{ lib, ... }:
let
  inherit (lib.nvim.dag) entryAnywhere;
in
{
  vim.luaConfigRC.dotfilesCommands = entryAnywhere ''
    -- mise.toml injections (the after/queries files in the live tree use this
    -- predicate to decide whether a `run` string is shell/TOML/etc.).
    require("vim.treesitter.query").add_predicate("is-mise?", function(_, _, bufnr, _)
      local path = vim.api.nvim_buf_get_name(tonumber(bufnr) or 0)
      local name = vim.fn.fnamemodify(path, ":t")
      return string.match(name, ".*mise.*%.toml$") ~= nil
    end, { force = true, all = false })

    -- Run git/crit in a floating terminal at the repository root. The
    -- toggleterm module is loaded lazily on first use.
    local function dotfiles_repo_root()
      local out = vim.fn.systemlist({ "git", "rev-parse", "--show-toplevel" })
      if vim.v.shell_error == 0 and out[1] and out[1] ~= "" then
        return out[1]
      end
      return vim.fn.getcwd()
    end

    local function dotfiles_terminal(cmd)
      local Terminal = require("toggleterm.terminal").Terminal
      Terminal:new({
        cmd = cmd,
        dir = dotfiles_repo_root(),
        direction = "float",
        hidden = true,
      }):toggle()
    end

    vim.api.nvim_create_user_command("Git", function(args)
      dotfiles_terminal("git " .. table.concat(args.fargs, " "))
    end, { nargs = "*", desc = "Run git at the repository root" })

    vim.api.nvim_create_user_command("Crit", function()
      dotfiles_terminal("crit")
    end, { desc = "Review the current changes with crit" })

    vim.api.nvim_create_user_command("FormatToggle", function()
      vim.g.nvf_format_save = not vim.g.nvf_format_save
      vim.notify("format-on-save " .. (vim.g.nvf_format_save and "enabled" or "disabled"))
    end, { desc = "Toggle conform format-on-save globally" })

    -- Defer loading fzf-lua until a UI select actually needs it.
    local fzf_ready = false
    local native_select = vim.ui.select
    vim.ui.select = function(items, opts, on_choice)
      if not fzf_ready then
        local ok, fzf = pcall(require, "fzf-lua")
        if ok then
          fzf.register_ui_select()
          fzf_ready = true
        else
          return native_select(items, opts, on_choice)
        end
      end
      vim.ui.select(items, opts, on_choice)
    end
  '';
}
