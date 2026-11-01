vim.opt_local.spell = true
vim.opt_local.spelllang = { "id", "en" }
vim.opt_local.wrap = false
vim.opt_local.linebreak = true
vim.opt_local.conceallevel = 2

vim.keymap.set("n", "<leader>tp", "<cmd>TypstPreviewToggle<cr>", {
  buffer = true,
  silent = true,
  desc = "Typst: toggle preview",
})
