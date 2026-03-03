return {
  -- { "nvim-mini/mini.ai", version = "*", opts = {} },
  -- { "nvim-mini/mini.comment", version = "*", opts = {} },
  { "nvim-mini/mini.cursorword", version = "*", opts = {} },
  { "nvim-mini/mini.hipatterns", version = "*", opts = {} },
  { "nvim-mini/mini.icons", version = "*", opts = {} },
  -- { "nvim-mini/mini.indentscope", version = "*", opts = {} },
  -- { "nvim-mini/mini.keymap", version = "*", opts = {} },
  { "nvim-mini/mini.move", version = "*", opts = {} },
  { "nvim-mini/mini.pairs", version = "*", opts = {} },
  -- { "nvim-mini/mini.pick", version = "*", opts = {} },
  { "nvim-mini/mini.splitjoin", version = "*", opts = {} },
  { "nvim-mini/mini.surround", version = "*", opts = {} },
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
  -- { "nvim-mini/mini.extra", version = "*", opts = {} },
}
