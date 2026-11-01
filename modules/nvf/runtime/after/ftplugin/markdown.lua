-- Native markdown comfort settings. Rendering is a deliberate action.
vim.opt_local.spell = true
vim.opt_local.spelllang = { "id", "en" }
vim.opt_local.wrap = false
vim.opt_local.linebreak = true
vim.opt_local.conceallevel = 2

local function map(lhs, rhs, desc)
  vim.keymap.set("n", lhs, rhs, { buffer = true, silent = true, desc = desc })
end

map("<leader>mr", "<cmd>RenderMarkdown buf_toggle<cr>", "Markdown: toggle render")
map("<leader>mR", "<cmd>RenderMarkdown preview<cr>", "Markdown: split preview")
map("<leader>tm", "<cmd>RenderMarkdown buf_toggle<cr>", "Markdown: toggle render")
map("<leader>tp", "<cmd>MdKite<cr>", "Markdown: live preview")
