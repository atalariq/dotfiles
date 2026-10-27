-- Nix: modules/40-languages.nix (emmet/tailwind servers; ftplugin-local options stay here)
vim.opt_local.tabstop = 2
vim.opt_local.shiftwidth = 2

local ok, emmet = pcall(require, "nvim-emmet")
if ok then
  vim.keymap.set({ "n", "v" }, "<leader>xe", emmet.wrap_with_abbreviation)
end
