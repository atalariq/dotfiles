-- Nix: modules/00-core.nix (build-time globals and aliases), modules/90-runtime.nix (runtimepath and dotfiles_* globals); leader keys stay here
-- Neovim behaviour; nvf supplies the reproducible plugin and tool package.

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
