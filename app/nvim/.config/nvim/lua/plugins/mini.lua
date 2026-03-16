return {
  { "nvim-mini/mini.cursorword", version = "*", opts = {} },
  { "nvim-mini/mini.hipatterns", version = "*", opts = {} },
  { "nvim-mini/mini.icons", version = "*", opts = {} },
  { "nvim-mini/mini.ai", version = "*", opts = {} },
  { "nvim-mini/mini.splitjoin", version = "*", opts = {} },
  { "nvim-mini/mini.move", version = "*", opts = {} },
  {
    "nvim-mini/mini.pairs",
    version = "*",
    opts = {
      modes = { insert = true, command = false, terminal = false },
      skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
      skip_ts = { "string" },
      skip_unbalanced = true,
      markdown = true,
    },
  },
  {
    "nvim-mini/mini.surround",
    version = "*",
    opts = {
      mappings = {
        add = "gsa", -- Add surrounding in Normal and Visual modes
        delete = "gsd", -- Delete surrounding
        find = "gsf", -- Find surrounding (to the right)
        find_left = "gsF", -- Find surrounding (to the left)
        highlight = "gsh", -- Highlight surrounding
        replace = "gsr", -- Replace surrounding
        update_n_lines = "gsn", -- Update `n_lines`
      },
    },
  },
  {
    "nvim-mini/mini.align",
    version = "*",
    opts = {
      mappings = {
        start = "ga",
        start_with_preview = "gA",
      },
      options = {
        split_pattern = "",
        justify_side = "left",
        merge_delimiter = "",
      },
      silent = false,
    },
  },
  { "nvim-mini/mini.extra", version = "*", opts = {} },
}
