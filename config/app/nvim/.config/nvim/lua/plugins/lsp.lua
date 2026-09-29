-- Shared language tooling: prefer system binaries from PATH.
-- No Mason here. If a server/formatter/linter is missing, install it through the
-- system package manager or the language toolchain that actually owns it.

local executable = require("core.utils").executable
local root_has = require("core.utils").root_has

local lazydev_ok, lazydev = pcall(require, "lazydev")
if lazydev_ok then
  lazydev.setup({
    library = {
      vim.env.VIMRUNTIME,
      -- See the configuration section for more details
      -- Load luvit types when the `vim.uv` word is found
      { path = "${3rd}/luv/library", words = { "vim%.uv" } },
    },
  })
end

local go_ok, go = pcall(require, "go")
if go_ok then
  go.setup({
    lsp_format = "none", -- matiin go.nvim's own format
  })
end

local servers = {
  basedpyright = { _cmd = "basedpyright" },
  bashls = { _cmd = "bash-language-server" },
  clangd = { _cmd = "clangd" },
  cssls = { _cmd = "vscode-css-language-server" },
  gopls = { _cmd = "gopls" },
  -- harper_ls = {
  --   _cmd = "harper-ls",
  --   cmd = { "harper-ls", "--stdio" },
  --   filetypes = { "markdown", "text", "tex", "typst" },
  -- },
  html = { _cmd = "vscode-html-language-server" },
  jsonls = { _cmd = "vscode-json-language-server" },
  marksman = { _cmd = "marksman" },
  oxlint = { _cmd = "oxlint" },
  rust_analyzer = { _cmd = "rust-analyzer" },
  tailwindcss = { _cmd = "tailwindcss-language-server" },
  tinymist = { _cmd = "tinymist" },
  tombi = { _cmd = "tombi" },
  emmet_language_server = {
    _cmd = "emmet-language-server",
    filetypes = {
      "css",
      "eruby",
      "html",
      "javascript",
      "javascriptreact",
      "less",
      "sass",
      "scss",
      "pug",
      "typescriptreact",
    },
  },
  vtsls = {
    _cmd = "vtsls",
    settings = {
      typescript = {
        preferences = { importModuleSpecifier = "non-relative" },
        suggest = { completeFunctionCalls = true },
      },
    },
  },
}

for name, server in pairs(servers) do
  local cmd = server._cmd
  server._cmd = nil
  vim.lsp.config(name, server)
  if not cmd or executable(cmd) then
    vim.lsp.enable(name)
  end
end

-- Optional low-noise typo diagnostics. Keep typos_lsp/codebook_lsp out globally;
-- they are easy to enable per-project later if they prove quiet enough.
if executable("typos-lsp") and root_has(0, { "typos.toml", "_typos.toml", ".typos.toml" }) then
  vim.lsp.enable("typos_lsp")
end
