-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.g.autoformat = false
vim.g.editorconfig = true
vim.g.ai_cmp = false
vim.g.root_spec = {  "lsp", { "src", "report" },".git", "cwd" }
vim.g.trouble_lualine = true

-- vim.opt.autochdir = true
vim.opt.autoread = true
vim.opt.clipboard = vim.env.SSH_CONNECTION and "" or "unnamedplus"
vim.opt.expandtab = true
vim.opt.number = true -- Print line number
vim.opt.relativenumber = true -- Relative line numbers
vim.opt.shiftwidth = 2 -- Size of an indent
vim.opt.wrap = false -- Disable line wrap
