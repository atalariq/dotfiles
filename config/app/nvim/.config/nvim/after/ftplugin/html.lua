vim.opt_local.tabstop = 2
vim.opt_local.shiftwidth = 2

vim.keymap.set({ "n", "v" }, "<leader>xe", require("nvim-emmet").wrap_with_abbreviation)
