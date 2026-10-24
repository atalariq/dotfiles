vim.opt_local.spell = true
vim.opt_local.spelllang = { "id", "en" }
vim.opt_local.wrap = false
vim.opt_local.linebreak = true
vim.opt_local.conceallevel = 2

-- --- typst-preview ---------------------------------------
local ok, preview = pcall(require, "typst-preview")
if ok and vim.fn.executable("tinymist") == 1 and vim.fn.executable("websocat") == 1 then
  preview.setup({
    debug = false,
    invert_colors = "never",
    follow_cursor = true,
    dependencies_bin = {
      tinymist = vim.fn.exepath("tinymist"),
      websocat = vim.fn.exepath("websocat"),
    },
  })
  vim.keymap.set("n", "<leader>ttp", "<cmd>TypstPreviewToggle<CR>", { desc = "Toggle typst preview" })
end
