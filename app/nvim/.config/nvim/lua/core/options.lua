-- core editor options

vim.opt.termguicolors = true
vim.opt.mouse = "a"

-- line numbers
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"
vim.opt.cursorline = true

-- tabs & indentation
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.breakindent = true

-- search
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.inccommand = "split"

-- clipboard
vim.opt.clipboard = "unnamedplus"

-- UI
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.opt.wrap = false
vim.opt.showmode = false

-- persistence
vim.opt.undofile = true
vim.opt.backup = false
vim.opt.swapfile = false
vim.opt.autoread = true

-- completion menu
vim.opt.pumheight = 10
vim.opt.completeopt = "menu,menuone,noselect"

-- split behavior
vim.opt.splitbelow = true
vim.opt.splitright = true

-- diagnostics
vim.diagnostic.config({
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "󰅚 ",
      [vim.diagnostic.severity.WARN] = "󰀪 ",
      [vim.diagnostic.severity.INFO] = "󰋽 ",
      [vim.diagnostic.severity.HINT] = "󰌵 ",
    },
  },
  virtual_text = true,
  update_in_insert = false,
})
