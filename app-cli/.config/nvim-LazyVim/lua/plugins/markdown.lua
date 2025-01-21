return {

  -- web preview
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    build = function()
      require("lazy").load({ plugins = { "markdown-preview.nvim" } })
      vim.fn["mkdp#util#install"]()
    end,
    keys = {
      {
        "<leader>tp",
        ft = "markdown",
        "<cmd>MarkdownPreviewToggle<cr>",
        desc = "Markdown Preview",
      },
    },
    config = function()
      vim.cmd([[do FileType]])
    end,
  },

  -- Markdown keybinds
  {
    "tadmccorkle/markdown.nvim",
    ft = "markdown", -- or 'event = "VeryLazy"'
    opts = {
      -- configuration here or empty for defaults
    },
  },

  -- better markdown viewer/renderer
  {
    "MeanderingProgrammer/render-markdown.nvim",

    keys = {
      { "<Leader>tr", "<Cmd>RenderMarkdown toggle<Cr>"}
    },
    opts = {
      code = {
        sign = false,
        style = "normal",
        width = "block",
        border = "thick",
        right_pad = 2,
        left_pad = 2,
      },
      heading = {
        sign = false,
        icons = {},
        position = "inline",
        -- border = true,
      },
      latex = { enabled = false },
      link = { enabled = false },
      bullet = { enabled = false },
      sign = { enabled = false },
      pipe_table = {
        enabled = false,
        preset = "round",
        style = "full",
        alignment_indicator = "━",
        cell = "trimmed",
      },
      callout = {},
    },
    ft = { "markdown" },
  },

  -- table mode
  {
    "Kicamon/markdown-table-mode.nvim",
    config = function()
      require("markdown-table-mode").setup()
    end,
  },
}
