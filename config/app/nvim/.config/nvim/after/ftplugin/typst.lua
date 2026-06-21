vim.opt_local.spell = true
vim.opt_local.spelllang = { "id", "en" }
vim.opt_local.wrap = false
vim.opt_local.linebreak = true
vim.opt_local.conceallevel = 2

-- --- typst-preview ---------------------------------------
require("typst-preview").setup({
  debug = false,
  -- open_cmd = "/opt/brave-bin/brave --app=%s --profile-directory=Default --app-id=previewer",
  invert_colors = "never",
  follow_cursor = true,
  dependencies_bin = {
    tinymist = "/usr/bin/tinymist",
    websocat = "/usr/bin/websocat",
  },
})

vim.keymap.set("n", "<leader>ttp", "<cmd>TypstPreviewToggle<CR>", { desc = "Toggle typst preview" })
