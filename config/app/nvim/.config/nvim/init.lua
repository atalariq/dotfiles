-- ================= minimal vim.pack-based Neovim config

-- leader key must be set before loading anything
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- icons
vim.g.have_nerd_font = true

-- Prepend mise shims to PATH
vim.env.PATH = vim.env.HOME .. "/.local/share/mise/shims:" .. vim.env.PATH

-- load config modules
require("core.options")
require("core.keymaps")
require("core.autocmds")

require("plugins")
require("colorscheme")
