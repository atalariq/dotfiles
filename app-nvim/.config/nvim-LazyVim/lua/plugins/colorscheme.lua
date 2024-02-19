return {
  -- best theme for vim
  {
    "folke/tokyonight.nvim",
    lazy = true,
    opts = { style = "moon" },
  },

  -- make vim transparent
  {
    "xiyaowong/transparent.nvim",
    lazy = false,
    config = function()
      vim.cmd("TransparentEnable")
    end,
  },
}
