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
  bashls = { _cmd = "bash-language-server" },
  gopls = { _cmd = "gopls" },
  rust_analyzer = { _cmd = "rust-analyzer" },
  basedpyright = { _cmd = "basedpyright" },
  vtsls = {
    _cmd = "vtsls",
    settings = {
      typescript = {
        preferences = { importModuleSpecifier = "non-relative" },
        suggest = { completeFunctionCalls = true },
      },
    },
  },
  eslint = { _cmd = "eslint-language-server" },
  tailwindcss = { _cmd = "tailwindcss-language-server" },
  html = { _cmd = "vscode-html-language-server" },
  cssls = { _cmd = "vscode-css-language-server" },
  jsonls = { _cmd = "vscode-json-language-server" },
  yamlls = { _cmd = "yaml-language-server" },
  dockerls = { _cmd = "docker-langserver" },
  jdtls = { _cmd = "jdtls" },
  phpactor = { _cmd = "phpactor" },
  tinymist = { _cmd = "tinymist" },
  texlab = { _cmd = "texlab" },
  marksman = { _cmd = "marksman" },
  -- sqls = { _cmd = "sqls" },
  postgres_lsp = { _cmd = "postgres-language-server" },
  clangd = { _cmd = "clangd" },
  systemd_ls = { _cmd = "systemd-lsp" },
  tombi = { _cmd = "tombi" },
  just = { _cmd = "just-lsp" },
  kotlin_lsp = {
    _cmd = "kotlin-lsp",
    cmd = { "kotlin-lsp", "--stdio" },
  },
  -- lua_ls = {
  --   _cmd = "lua-language-server",
  -- },
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
