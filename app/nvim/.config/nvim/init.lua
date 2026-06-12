--[[
dotfiles/nvim — minimal vim.pack-based Neovim config
]]

-- leader key must be set before loading anything
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- icons
vim.g.have_nerd_font = true

-- load config modules
require("core.options")
require("core.keymaps")
require("core.autocmds")

require("plugins")
require("colorscheme")
