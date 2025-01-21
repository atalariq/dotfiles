-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

local function augroup(name)
  return vim.api.nvim_create_augroup("user_" .. name, { clear = true })
end

vim.api.nvim_create_autocmd("FileType", {
  group = augroup("spell"),
  pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.spelllang = { "en" }
  end,
})

vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
  group = augroup("obsidian-notes"),
  pattern = { "*/Sync/Notes/**.md" },
  callback = function ()
    vim.opt_local.spell = true
    vim.opt_local.spelllang = { "id" }
  end
})

vim.api.nvim_create_autocmd("FileType", {
  group = augroup("nowrap"),
  pattern = { "markdown" },
  callback = function()
    vim.opt_local.wrap = false
  end,
})
