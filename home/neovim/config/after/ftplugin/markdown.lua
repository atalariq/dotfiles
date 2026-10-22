vim.opt_local.spell = true
vim.opt_local.spelllang = { "id", "en" }
vim.opt_local.wrap = false
vim.opt_local.linebreak = true
vim.opt_local.conceallevel = 2

-- --- mdkite ---------------------------------
local has_mdkite, mdkite = pcall(require, "mdkite")
if has_mdkite then
  mdkite.setup({
    -- all optional; sane defaults shown
    instance_mode = "takeover", -- "takeover" (one tab) or "multi" (tab per instance)
    port = 0, -- 0 = auto (8421 for takeover, OS-assigned for multi)
    open_browser = true,
    default_theme = "dark", -- "dark" or "light"; initial preview theme
    debounce_ms = 300,
  })

  -- markdown preview
  vim.keymap.set("n", "<leader>tlp", "<cmd>MdKite<CR>", { desc = "Toggle Markdown Live Preview" })
end

-- --- render-markdown -------------------------------------
local has_renderer, renderer = pcall(require, "render-markdown")
if has_renderer then
  renderer.setup({
    enabled = false,
    preset = "obsidian",
    render_modes = { "n", "c" }, -- nonaktif saat insert
    completions = { lsp = { enabled = true } },
    anti_conceal = { enabled = true },
    latex = { enabled = false },
    nested = false,
  })

  vim.keymap.set("n", "<leader>tm", "<cmd>RenderMarkdown buf_toggle<CR>", { desc = "Toggle markdown renderer" })
end
