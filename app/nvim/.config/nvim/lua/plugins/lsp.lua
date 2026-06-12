-- Shared language tooling: prefer system binaries from PATH.
-- Mason plugins may stay installed as fallback, but this config does not ask Mason
-- to install or resolve tools.

local function executable(cmd)
  return vim.fn.executable(cmd) == 1
end

local function root_has(bufnr, names)
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  local start = bufname ~= "" and vim.fs.dirname(bufname) or vim.uv.cwd()
  local found = vim.fs.find(names, { upward = true, path = start })
  return #found > 0
end

local servers = {
  bashls = {},
  lua_ls = {
    on_init = function(client)
      client.server_capabilities.documentFormattingProvider = false

      if client.workspace_folders then
        local path = client.workspace_folders[1].name
        if
          path ~= vim.fn.stdpath("config")
          and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
        then
          return
        end
      end

      client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
        runtime = {
          version = "LuaJIT",
          path = { "lua/?.lua", "lua/?/init.lua" },
        },
        workspace = {
          checkThirdParty = false,
          library = vim.tbl_extend("force", vim.api.nvim_get_runtime_file("", true), {
            "${3rd}/luv/library",
            "${3rd}/busted/library",
          }),
        },
      })
    end,
    settings = {
      Lua = {
        format = { enable = false },
      },
    },
  },
  gopls = {},
  rust_analyzer = {},
  basedpyright = {},
  vtsls = {},
  eslint = {},
  tailwindcss = {},
  html = {},
  cssls = {},
  jsonls = {},
  yamlls = {},
  dockerls = {},
  jdtls = {},
  kotlin_lsp = {
    -- Arch package exposes kotlin-lsp, while lspconfig's default currently uses intellij-server.
    cmd = { "kotlin-lsp", "--stdio" },
  },
  phpactor = {},
  tinymist = {},
  texlab = {},
  marksman = {},
  -- Keep SQL to one global client. postgres_lsp attaches only in projects with
  -- postgres-language-server.jsonc, avoiding a global sqls duplicate.
  postgres_lsp = {},
  clangd = {},
  systemd_ls = {},
  tombi = {},
  just = {},
}

local server_commands = {
  bashls = "bash-language-server",
  lua_ls = "lua-language-server",
  gopls = "gopls",
  rust_analyzer = "rust-analyzer",
  basedpyright = "basedpyright",
  vtsls = "vtsls",
  eslint = "eslint-language-server",
  tailwindcss = "tailwindcss-language-server",
  html = "vscode-html-language-server",
  cssls = "vscode-css-language-server",
  jsonls = "vscode-json-language-server",
  yamlls = "yaml-language-server",
  dockerls = "dockerfile-language-server",
  jdtls = "jdtls",
  kotlin_lsp = "kotlin-lsp",
  phpactor = "phpactor",
  tinymist = "tinymist",
  texlab = "texlab",
  marksman = "marksman",
  postgres_lsp = "postgres-language-server",
  clangd = "clangd",
  systemd_ls = "systemd-lsp",
  tombi = "tombi",
  just = "just-lsp",
}

for name, server in pairs(servers) do
  vim.lsp.config(name, server)

  local cmd = server_commands[name]
  if not cmd or executable(cmd) then
    vim.lsp.enable(name)
  end
end

-- Optional low-noise typo diagnostics. Keep typos_lsp/codebook_lsp out globally;
-- they are easy to enable per-project later if they prove quiet enough.
if executable("typos-lsp") and root_has(0, { "typos.toml", "_typos.toml", ".typos.toml" }) then
  vim.lsp.enable("typos_lsp")
end

-- --- Linter -------------------------------------------------------

local lint = require("lint")

lint.linters_by_ft = {
  sh = { "shellcheck" },
  bash = { "shellcheck" },
  dockerfile = { "hadolint" },
  yaml = { "yamllint" },
  python = { "ruff" },
  go = { "golangcilint" },
  lua = { "selene" },
  sql = { "sqlfluff" },
  markdown = { "typos" },
  text = { "typos" },
}

local lint_augroup = vim.api.nvim_create_augroup("user_lint", { clear = true })
vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
  group = lint_augroup,
  callback = function()
    if vim.bo.modifiable then
      lint.try_lint()
    end
  end,
})

-- --- Formatter ----------------------------------------------------

vim.g.autoformat_enabled = vim.g.autoformat_enabled ~= false

local function js_formatter(bufnr)
  if root_has(bufnr, { "biome.json", "biome.jsonc" }) then
    return { "biome" }
  end
  return { "prettier" }
end

local function markdown_formatter(bufnr)
  if
    root_has(bufnr, {
      ".prettierrc",
      ".prettierrc.json",
      ".prettierrc.yaml",
      ".prettierrc.yml",
      "prettier.config.js",
      "prettier.config.mjs",
    })
  then
    return { "prettier" }
  end
  return { "rumdl" }
end

require("conform").setup({
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
    lua = { "stylua" },
    sh = { "shfmt" },
    bash = { "shfmt" },
    go = { "gofumpt" },
    typst = { "typstyle" },
    sql = { "pg_format" },
    mysql = { "pg_format" },
    plsql = { "pg_format" },
    yaml = { "yamlfmt" },
    json = { "biome", "prettier", stop_after_first = true },
    jsonc = { "biome", "prettier", stop_after_first = true },
    javascript = js_formatter,
    javascriptreact = js_formatter,
    typescript = js_formatter,
    typescriptreact = js_formatter,
    html = { "prettier" },
    css = { "prettier" },
    scss = { "prettier" },
    java = { "google-java-format" },
    kotlin = { "ktlint" },
    dart = { "dart_format" },
    markdown = markdown_formatter,
  },
})

vim.api.nvim_create_user_command("FormatToggle", function()
  vim.g.autoformat_enabled = not vim.g.autoformat_enabled
  vim.notify("format-on-save " .. (vim.g.autoformat_enabled and "enabled" or "disabled"))
end, { desc = "Toggle conform.nvim format-on-save" })
