-- lua/core/utils.lua
local M = {}

function M.executable(cmd)
  return vim.fn.executable(cmd) == 1
end

function M.root_has(bufnr, names)
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  local start = bufname ~= "" and vim.fs.dirname(bufname) or vim.uv.cwd()
  local found = vim.fs.find(names, { upward = true, path = start })
  return #found > 0
end

return M
