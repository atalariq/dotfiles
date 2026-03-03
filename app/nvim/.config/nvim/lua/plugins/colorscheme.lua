return {
  {
    "neanias/everforest-nvim",
    name = "everforest",
    lazy = false,
    priority = 1000,
    opts = {
      background = "medium", -- option: soft|medium|hard
      transparent_background_level = 2,
      italics = true,
      ui_contrast = "low", -- option: low|high
      float_style = "dim", -- option: bright|dim
    },
  },
  {
    "kepano/flexoki-neovim",
    name = "flexoki",
    lazy = false,
    priority = 1000,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "everforest",
    },
  },
}
