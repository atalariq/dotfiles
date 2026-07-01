local lint = require("lint")

local linters = {
  selene = {
    append_args = { "--config", vim.fn.stdpath("config") .. "/selene.toml" },
  },
  vale = { append_args = { "--config", vim.fn.expand("~/.config/vale/.vale.ini"), "--output", "JSON" } },
  rumdl = {
    append_args = {
      "--no-cache",
      "--config",
      'global.disable = [ "MD013", "MD022", "MD032", "MD064" ]',
      -- "--config",
      -- "MD013.line-length = 120",
    },
  },
}

local linters_by_ft = {
  sh = { "shellcheck" },
  bash = { "shellcheck" },
  fish = { "fish" },
  dockerfile = { "hadolint" },
  yaml = { "yamllint" },
  python = { "ruff" },
  go = { "golangcilint" },
  lua = { "selene" },
  sql = { "sqlfluff" },
  -- markdown = { "vale", "rumdl" },
  markdown = { "rumdl" },
  ["_"] = { "typos" },
}

for name, linter in pairs(linters) do
  if type(linter) == "table" and type(lint.linters[name]) == "table" then
    lint.linters[name] = vim.tbl_deep_extend("force", lint.linters[name], linter)
    if type(linter.append_args) == "table" then
      lint.linters[name].args = lint.linters[name].args or {}
      vim.list_extend(lint.linters[name].args, linter.append_args)
    end
  else
    lint.linters[name] = linter
  end
end
lint.linters_by_ft = linters_by_ft

-- Stolen from https://www.lazyvim.org/plugins/linting
local function debounce(ms, fn)
  local timer = vim.uv.new_timer()
  return function(...)
    local argv = { ... }
    timer:start(ms, 0, function()
      timer:stop()
      vim.schedule_wrap(fn)(unpack(argv))
    end)
  end
end

local function __lint()
  -- Use nvim-lint's logic first:
  -- * checks if linters exist for the full filetype first
  -- * otherwise will split filetype by "." and add all those linters
  -- * this differs from conform.nvim which only uses the first filetype that has a formatter
  local names = lint._resolve_linter_by_ft(vim.bo.filetype)

  -- Create a copy of the names table to avoid modifying the original.
  names = vim.list_extend({}, names)

  -- Add fallback linters.
  if #names == 0 then
    vim.list_extend(names, lint.linters_by_ft["_"] or {})
  end

  -- Add global linters.
  vim.list_extend(names, lint.linters_by_ft["*"] or {})

  -- Filter out linters that don't exist or don't match the condition.
  local ctx = { filename = vim.api.nvim_buf_get_name(0) }
  ctx.dirname = vim.fn.fnamemodify(ctx.filename, ":h")
  names = vim.tbl_filter(function(name)
    local linter = lint.linters[name]
    if not linter then
      vim.notify("Linter not found: " .. name, vim.log.levels.WARN, { title = "nvim-lint" })
    end
    return linter and not (type(linter) == "table" and linter.condition and not linter.condition(ctx))
  end, names)

  -- Run linters.
  if #names > 0 then
    lint.try_lint(names)
  end
end

vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
  group = vim.api.nvim_create_augroup("user_lint", { clear = true }),
  callback = debounce(100, __lint),
})
