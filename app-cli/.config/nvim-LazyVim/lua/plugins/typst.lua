return {
  {
    "chomosuke/typst-preview.nvim",
    ft = 'typst',
    version = "1.*",
    opts = {
      invert_colors = "never",
      follow_cursor = true,
      dependencies_bin = { ["tinymist"] = "tinymist" },
    },
  },
}
