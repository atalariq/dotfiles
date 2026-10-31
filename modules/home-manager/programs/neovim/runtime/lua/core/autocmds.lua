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

-- Legacy IDE-feel additions ported from the old config (2026-10). The yank
-- highlight above already covers that behaviour, so it is not duplicated.
vim.api.nvim_create_autocmd("FileChangedShellPost", {
  group = group,
  callback = function()
    vim.notify("File changed on disk; buffer reloaded", vim.log.levels.WARN)
  end,
})

-- LSP buffer keys that the 0.11 natives do not cover.
vim.api.nvim_create_autocmd("LspAttach", {
  group = group,
  callback = function(ev)
    local function b(lhs, fn, desc)
      vim.keymap.set("n", lhs, fn, { buffer = ev.buf, desc = desc })
    end
    b("gd", vim.lsp.buf.definition, "Definition")
    b("<leader>ca", vim.lsp.buf.code_action, "Code action")
    b("<leader>cr", vim.lsp.buf.rename, "Rename")
    b(
      "<leader>th",
      function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf }), { bufnr = ev.buf })
      end,
      "Toggle inlay hints"
    )
  end,
})
