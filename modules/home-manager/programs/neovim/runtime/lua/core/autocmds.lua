-- Autocmds owned by this configuration.
local group = vim.api.nvim_create_augroup("Dotfiles", { clear = true })

-- Markdown is read raw first: rendering is a deliberate action, and the
-- plugin is only loaded when a markdown buffer opens.
vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = "markdown",
  callback = function(ev)
    local function map(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { buffer = ev.buf, silent = true, desc = desc })
    end
    map("<leader>mr", "<cmd>RenderMarkdown buf_toggle<cr>", "Markdown: toggle render")
    map("<leader>mR", "<cmd>RenderMarkdown preview<cr>", "Markdown: split preview")
  end,
})

-- `o` and `O` must not continue a comment.
vim.api.nvim_create_autocmd("FileType", {
  group = group,
  callback = function()
    vim.bo.formatoptions = vim.bo.formatoptions:gsub("[cr]", "")
  end,
})

-- Show where the cursor just was.
vim.api.nvim_create_autocmd("TextYankPost", {
  group = group,
  callback = function()
    vim.highlight.on_yank({ timeout = 120 })
  end,
})
