-- colorscheme: everforest

vim.o.background = "dark"

local ok, everforest = pcall(require, "everforest")
if ok then
  everforest.setup({
    background = "medium", -- "soft", "medium" (default), or "hard".
    transparent_background_level = 2, -- 0 (default), 1, or 2
    ui_contrast = "high", -- "high" or "low" (default).
  })
  everforest.load()
else
  vim.notify("everforest not found, falling back to habamax", vim.log.levels.WARN)
  vim.cmd("colorscheme habamax")
end
