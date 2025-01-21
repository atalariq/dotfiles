return {
  -- Aligner
  { "echasnovski/mini.align", config = true },

  -- Toggle comment easily
  {
    "numToStr/Comment.nvim",
    opts = {
      toggler = { line = "gcc", block = "gbc" },
      opleader = { line = "gc", block = "gb" },
    },
  },
}
