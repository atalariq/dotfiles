local conform = require("conform")
local root_has = require("core.utils").root_has

vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
vim.g.autoformat_enabled = vim.g.autoformat_enabled ~= false

conform.formatters.vale =
  { append_args = { "--config", vim.fn.expand("~/.config/vale/.vale.ini"), "--output", "JSON" } }

conform.formatters.rumdl = {
  append_args = {
    "--config",
    'global.disable = [ "MD022", "MD032", "MD064" ]',
    "--config",
    "MD013.line-length = 120",
  },
}

conform.setup({
  notify_on_error = false,
  format_on_save = function(bufnr)
    if not vim.g.autoformat_enabled then
      return nil
    end

    local safe_filetypes = {
      lua = true,
      sh = true,
      bash = true,
      go = true,
      typst = true,
      yaml = true,
      json = true,
      jsonc = true,
    }

    if safe_filetypes[vim.bo[bufnr].filetype] then
      return { timeout_ms = 1000, lsp_format = "fallback" }
    end

    return nil
  end,
  default_format_opts = {
    lsp_format = "fallback",
  },
  formatters_by_ft = {
    bash = { "shfmt" },
    css = { "oxfmt", "prettier", stop_after_first = true },
    go = { "goimports", "gofumpt" },
    html = { "oxfmt", "prettier", stop_after_first = true },
    javascript = { "oxfmt", "prettier", stop_after_first = true },
    javascriptreact = { "oxfmt", "prettier", stop_after_first = true },
    json = { "oxfmt", "prettier", stop_after_first = true },
    jsonc = { "oxfmt", "prettier", stop_after_first = true },
    lua = { "stylua" },
    markdown = { "rumdl", "oxfmt", stop_after_first = true },
    sh = { "shfmt" },
    toml = { "tombi", "oxfmt", stop_after_first = true },
    typescript = { "oxfmt", "prettier", stop_after_first = true },
    typescriptreact = { "oxfmt", "prettier", stop_after_first = true },
    typst = { "typstyle" },
    yaml = { "yamlfmt", "oxfmt", stop_after_first = true },
    zsh = { "shfmt" },
  },
})

vim.api.nvim_create_user_command("FormatToggle", function()
  vim.g.autoformat_enabled = not vim.g.autoformat_enabled
  vim.notify("format-on-save " .. (vim.g.autoformat_enabled and "enabled" or "disabled"))
end, { desc = "Toggle conform.nvim format-on-save" })

-- conform
vim.keymap.set({ "n", "v" }, "<leader>cf", function()
  conform.format({ async = true })
end, { desc = "Format buffer" })

vim.keymap.set("n", "<leader>tf", "<cmd>FormatToggle<CR>", { desc = "Toggle format-on-save" })
