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
      mappings = {
        ["("] = { action = "open", pair = "()", neigh_pattern = "^[^\\]" },
        ["["] = { action = "open", pair = "[]", neigh_pattern = "^[^\\]" },
        ["{"] = { action = "open", pair = "{}", neigh_pattern = "^[^\\]" },

        [")"] = { action = "close", pair = "()", neigh_pattern = "^[^\\]" },
        ["]"] = { action = "close", pair = "[]", neigh_pattern = "^[^\\]" },
        ["}"] = { action = "close", pair = "{}", neigh_pattern = "^[^\\]" },

        ['"'] = { action = "closeopen", pair = '""', neigh_pattern = "^[^\\]", register = { cr = false } },
        ["'"] = { action = "closeopen", pair = "''", neigh_pattern = "^[^%a\\]", register = { cr = false } },
        ["`"] = { action = "closeopen", pair = "``", neigh_pattern = "^[^\\]", register = { cr = false } },
      },
    },
  },
  {
    "nvim-mini/mini.surround",
    version = "*",
    opts = {
      highlight_duration = 500,
      n_lines = 20,
      respect_selection_type = true,
      search_method = 'cover_or_nearest',
      mappings = {
        add = "gsa", -- Add surrounding in Normal and Visual modes
        delete = "gsd", -- Delete surrounding
        find = "gsf", -- Find surrounding (to the right)
        find_left = "gsF", -- Find surrounding (to the left)
        highlight = "gsh", -- Highlight surrounding
        replace = "gsr", -- Replace surrounding
        update_n_lines = "gsn", -- Update `n_lines`
        suffix_last = "l", -- Suffix to search with "prev" method
        suffix_next = "n", -- Suffix to search with "next" method
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
      -- options = {
      --   split_pattern = "",
      --   justify_side = "left",
      --   merge_delimiter = "",
      -- },
      silent = false,
    },
  },
  { "nvim-mini/mini.extra", version = "*", opts = {} },
}
