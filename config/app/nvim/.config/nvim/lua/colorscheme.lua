-- colorscheme: everforest

vim.o.background = "dark"

local ok, _ = pcall(require, "wana")

if ok then
  vim.o.background = "dark" -- or "light"
  vim.cmd.colorscheme("wana")
else
  vim.notify("everforest not found, falling back to habamax", vim.log.levels.WARN)
  vim.cmd("colorscheme habamax")
end
