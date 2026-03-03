return {
  "OXY2DEV/markview.nvim",
  lazy = false,
  keys = {
    { "<leader>m", "<CMD>Markview<CR>", { desc = "Toggle `markview` globally" } },
  },
  opts = {
    preview = {
      icon_provider = "mini", -- "internal" or "mini" or "devicons"
    },
    markdown = {
      list_items = {
        enable = true,
        wrap = true,
        marker_minus = { add_padding = false },
        marker_plus = { add_padding = false },
        marker_star = { add_padding = false },
        marker_dot = { add_padding = false },
        marker_parenthesis = { add_padding = false },
      },
    },
  },
}
