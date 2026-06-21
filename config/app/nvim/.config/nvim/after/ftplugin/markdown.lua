vim.opt_local.spell = true
vim.opt_local.spelllang = { "id", "en" }
vim.opt_local.wrap = false
vim.opt_local.linebreak = true
vim.opt_local.conceallevel = 2

-- --- live_server & markdown_preview ---------------------------------
require("markdown_preview").setup({
  instance_mode = "takeover", -- "takeover" (one tab) or "multi" (tab per instance)
  port = 0, -- 0 = auto (8421 for takeover, OS-assigned for multi)
  open_browser = true,
  default_theme = "dark", -- "dark" or "light"; initial preview theme
  debounce_ms = 300,
})

-- markdown preview
vim.keymap.set("n", "<leader>tlp", "<cmd>MarkdownPreview<CR>", { desc = "Toggle Live Preview markdown/html/asciidoc" })

-- --- render-markdown -------------------------------------
require("render-markdown").setup({
  render_modes = { "n", "c" }, -- nonaktif saat insert
  anti_conceal = { enabled = true },
  latex = { enabled = false },
})
