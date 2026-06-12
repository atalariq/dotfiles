-- colorscheme: everforest

vim.o.background = "dark"

local ok, _ = pcall(vim.cmd, "colorscheme everforest")
if not ok then
  vim.notify("everforest not found, falling back to habamax", vim.log.levels.WARN)
  vim.cmd("colorscheme habamax")
end
