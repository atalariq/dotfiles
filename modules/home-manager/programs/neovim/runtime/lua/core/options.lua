-- Options nvf does not own. Kept in the live tree so they can be tuned without
-- a rebuild; anything nvf declares stays there instead.
local o = vim.opt

o.scrolloff = 6
o.sidescrolloff = 8
o.splitright = true
o.splitbelow = true
o.ignorecase = true
o.smartcase = true
o.updatetime = 250
-- Blockwise visual editing past the end of the line.
o.virtualedit = "block"

-- 2026 community defaults + legacy parity (nvf defaults cover the rest).
vim.o.timeoutlen = 300
vim.o.updatetime = 250
vim.o.scrolloff = 8
vim.o.sidescrolloff = 8
vim.o.completeopt = "menu,menuone,noselect"
vim.o.virtualedit = "block"
if vim.fn.has("nvim-0.11") == 1 then
  vim.o.winborder = "rounded"
end

-- Spell: Indonesian + English. Personal words stay in the writable state dir
-- (`zg` appends to this file), never in the Nix store.
vim.o.spelllang = "en_us,id"
vim.o.spellfile = vim.fn.stdpath("data") .. "/spell/en.utf-8.add"
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "tex", "typst", "gitcommit", "text" },
  command = "setlocal spell",
})

-- Theme fallback: only set when stylix is disabled (default.nix injects
-- `dotfiles_theme`). Stylix-themed hosts never reach this branch.
if vim.g.dotfiles_theme == "wana" then
  if pcall(vim.cmd.colorscheme, "wana") then
    vim.o.background = "dark"
  else
    vim.cmd.colorscheme("habamax") -- built-in fallback, matches legacy behavior
  end
end
