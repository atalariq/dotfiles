return {
  {
    "chomosuke/typst-preview.nvim",
    lazy = false,
    ft = "typst",
    version = "1.*",
    opts = {
      -- port = 0,
      -- open_cmd = nil,
      -- extra_args = nil,
      invert_colors = "never",
      follow_cursor = true,
      dependencies_bin = {
        ["tinymist"] = "tinymist",
        ["websocat"] = "websocat",
      },
    },
  },
}
