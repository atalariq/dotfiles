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
