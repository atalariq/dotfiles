-- Nix: modules/20-plugins.nix (fzf-lua), modules/00-core.nix (rg/fd/fzf/git), modules/90-runtime.nix (:DotfilesConfig globals)
-- --- fzf-lua ---------------------------------------------
require("fzf-lua").setup({
  "borderless",
})
require("fzf-lua").register_ui_select()

vim.keymap.set("n", "<leader><leader>", function()
  require("fzf-lua").buffers()
end, { desc = "Buffers" })
vim.keymap.set("n", "<leader>sc", function()
  require("fzf-lua").files({ cwd = "~/.config" })
end, { desc = "Edit configs" })

-- Generated ~/.config files are not the source of the packaged Lua runtime.
vim.api.nvim_create_user_command("DotfilesConfig", function()
  local source = vim.g.dotfiles_source_dir or vim.env.DOTFILES_NVIM_SOURCE
  if not source or source == "" or vim.fn.isdirectory(source) ~= 1 then
    vim.notify(
      "Neovim source checkout is unavailable; set dotfiles.deployment.checkout and rebuild.",
      vim.log.levels.ERROR
    )
    return
  end
  local live = vim.g.dotfiles_live_runtime
  if live == nil then
    -- Existing live installations can load this Lua before their wrapper rebuilds.
    local runtime = vim.g.dotfiles_config_dir
    live = runtime and vim.uv.fs_realpath(runtime) == vim.uv.fs_realpath(source) or false
  end
  local mode = live and "live; restart Neovim to reload" or "immutable; rebuild to apply edits"
  vim.notify("Editing " .. source .. " (" .. mode .. ")")
  require("fzf-lua").files({ cwd = source, prompt = "Neovim source (" .. mode .. ")> " })
end, { desc = "Edit canonical Neovim source configuration" })
vim.keymap.set("n", "<leader>sN", "<cmd>DotfilesConfig<CR>", { desc = "Edit Neovim source" })
vim.keymap.set("n", "<leader>sD", function()
  require("fzf-lua").diagnostics_workspace()
end, { desc = "Workspace diagnostics" })
vim.keymap.set("n", "<leader>sd", function()
  require("fzf-lua").diagnostics_document()
end, { desc = "Document diagnostics" })
vim.keymap.set("n", "<leader>sf", function()
  require("fzf-lua").files()
end, { desc = "Find files" })
vim.keymap.set("n", "<leader>sg", function()
  require("fzf-lua").live_grep()
end, { desc = "Live grep" })
vim.keymap.set("n", "<leader>sh", function()
  require("fzf-lua").help_tags()
end, { desc = "Help tags" })
vim.keymap.set("n", "<leader>sk", function()
  require("fzf-lua").keymaps()
end, { desc = "Keymaps" })
vim.keymap.set("n", "<leader>so", function()
  require("fzf-lua").oldfiles()
end, { desc = "Oldfiles/history" })
vim.keymap.set("n", "<leader>sp", function()
  require("fzf-lua").builtin()
end, { desc = "Search pickers" })
vim.keymap.set("n", "<leader>sr", function()
  require("fzf-lua").resume()
end, { desc = "Resume last search" })
vim.keymap.set("n", "<leader>st", function()
  require("fzf-lua").tags_live_grep()
end, { desc = "Tags project (live grep)" })
vim.keymap.set("n", "<leader>sw", function()
  require("fzf-lua").grep_cword()
end, { desc = "Grep word under cursor" })
vim.keymap.set("n", "<leader>sz", function()
  require("fzf-lua").zoxide()
end, { desc = "Zoxide" })
