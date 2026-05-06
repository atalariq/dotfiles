return {
  {
    "https://github.com/Weyaaron/nvim-training",
    pin = true,
    opts = {},
  },
  {
    "m4xshen/hardtime.nvim",
    enabled = false,
    lazy = false,
    dependencies = { "MunifTanjim/nui.nvim" },
    opts = {
      disable_mouse = false,
    },
    keys = {
      { "<leader>H", "<Cmd>Hardtime toggle<CR>", desc = "Hardtime toggle" },
    }
  },
  {
    "saxon1964/neovim-tips",
    enabled = false,
    version = "*", -- Only update on tagged releases
    lazy = true, -- Load only when keybinds are triggered
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
    opts = {
      daily_tip = 1, -- 0 = off, 1 = once per day, 2 = every startup
      bookmark_symbol = "🌟 ",
    },
    keys = {
      { "<leader>to", ":NeovimTips<CR>", desc = "Neovim tips" },
      { "<leader>tb", ":NeovimTipsBookmarks<CR>", desc = "Bookmarked tips" },
      { "<leader>tr", ":NeovimTipsRandom<CR>", desc = "Show random tip" },
      { "<leader>te", ":NeovimTipsEdit<CR>", desc = "Edit your tips" },
      { "<leader>ta", ":NeovimTipsAdd<CR>", desc = "Add your tip" },
      { "<leader>tp", ":NeovimTipsPdf<CR>", desc = "Open tips PDF" },
    },
  },
}
