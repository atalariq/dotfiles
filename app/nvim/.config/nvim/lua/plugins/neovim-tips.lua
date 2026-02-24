return {
  "saxon1964/neovim-tips",
  version = "*",
  lazy = true, -- Load only when keybinds are triggered
  dependencies = {
    "MunifTanjim/nui.nvim",
  },
  opts = {
    bookmark_symbol = "🌟 ",
    daily_tip = 0,
  },
  keys = {
    { "<leader>to", ":NeovimTips<CR>", desc = "Neovim tips" },
    { "<leader>tb", ":NeovimTipsBookmarks<CR>", desc = "Bookmarked tips" },
    { "<leader>tr", ":NeovimTipsRandom<CR>", desc = "Show random tip" },
    { "<leader>te", ":NeovimTipsEdit<CR>", desc = "Edit your tips" },
    { "<leader>ta", ":NeovimTipsAdd<CR>", desc = "Add your tip" },
    { "<leader>tp", ":NeovimTipsPdf<CR>", desc = "Open tips PDF" },
  },
}
