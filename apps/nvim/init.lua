vim.opt.number = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.termguicolors = true
vim.opt.undofile = true
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.g.mapleader = ' '
-- Start with the built-in editor: no plugin downloads or invented lockfiles.
-- Project toolchains and LSP servers belong in the project's development shell.
local local_config = vim.fn.stdpath('config') .. '/init.local.lua'
if vim.fn.filereadable(local_config) == 1 then dofile(local_config) end
