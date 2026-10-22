-- The portable palette is an ordinary Lua file; missing optional assets are safe.
local has_palette, theme = pcall(require, "theme.palette")
local has_base16, base16 = pcall(require, "mini.base16")
if has_palette and has_base16 then
  vim.o.background = theme.polarity or "dark"
  base16.setup({ palette = theme.palette })
else
  vim.cmd.colorscheme("habamax")
end
