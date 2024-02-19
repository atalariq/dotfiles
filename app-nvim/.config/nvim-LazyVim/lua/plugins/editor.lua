return {
  -- telescope override
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      {
        "nvim-telescope/telescope-frecency.nvim",
        config = function()
          require("telescope").load_extension("frecency")
        end,
      },
    },
    keys = {
      { "<C-p>", "<CMD>Telescope find_files<CR>", desc = "Find Files" },
      { "<leader>fh", "<CMD>Telescope oldfiles<CR>", desc = "oldfiles (file history)" },
      { "<leader>fl", "<CMD>Telescope live_grep<CR>", desc = "live Grep" },
      { "<leader>fk", "<CMD>Telescope keymaps<CR>", desc = "keymaps" },
      { "<leader>ff", "<CMD>Telescope frecency<CR>", desc = "keymaps" },
      { "<space><space>", false}
    },
  },

  {
    "NvChad/nvim-colorizer.lua",
    event = "BufReadPre",
    opts = {
      filetypes = { "*", "!lazy" },
      buftype = { "*", "!prompt", "!nofile" },
      user_default_options = {
        RGB = true, -- #RGB hex codes
        RRGGBB = true, -- #RRGGBB hex codes
        names = false, -- "Name" codes like Blue
        RRGGBBAA = true, -- #RRGGBBAA hex codes
        AARRGGBB = false, -- 0xAARRGGBB hex codes
        rgb_fn = true, -- CSS rgb() and rgba() functions
        hsl_fn = true, -- CSS hsl() and hsla() functions
        css = false, -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
        css_fn = true, -- Enable all CSS *functions*: rgb_fn, hsl_fn
        -- Available modes: foreground, background
        -- Available modes for `mode`: foreground, background,  virtualtext
        mode = "background", -- Set the display mode.
        virtualtext = "■",
      },
    },
  },

  -- Better word motion
  {
    "chrisgrieser/nvim-spider",
    keys = {
      { "w", "<cmd>lua require('spider').motion('w')<CR>", mode = { "n", "o", "x" }, desc = "Spider-w motion" },
      { "e", "<cmd>lua require('spider').motion('e')<CR>", mode = { "n", "o", "x" }, desc = "Spider-e motion" },
      { "b", "<cmd>lua require('spider').motion('b')<CR>", mode = { "n", "o", "x" }, desc = "Spider-b motion" },
      { "ge", "<cmd>lua require('spider').motion('ge')<CR>", mode = { "n", "o", "x" }, desc = "Spider-ge motion" },
    },
    opts = {},
  },

  -- Aligner
  { "echasnovski/mini.align", version = "*", config = true },

  -- Toggle comment easily
  { "echasnovski/mini.comment", enabled = false },
  {
    "numToStr/Comment.nvim",
    opts = {
      toggler = { line = "gcc", block = "gbc" },
      opleader = { line = "gc", block = "gb" },
    },
  },
}
