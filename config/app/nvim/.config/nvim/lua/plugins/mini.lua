-- mini.nvim plugins

if vim.g.have_nerd_font then
  require("mini.icons").setup()
end

require("mini.tabline").setup()

local statusline = require("mini.statusline")
statusline.setup({ use_icons = vim.g.have_nerd_font })
statusline.section_location = function()
  return "%2l:%-2v"
end

require("mini.bracketed").setup()
require("mini.cursorword").setup()
require("mini.hipatterns").setup()
require("mini.input").setup()
require("mini.jump").setup()
require("mini.jump2d").setup()
require("mini.move").setup()
require("mini.splitjoin").setup()

require("mini.ai").setup({
  -- NOTE: Avoid conflicts with the built-in incremental selection mappings on Neovim>=0.12 (see `:help treesitter-incremental-selection`)
  mappings = {
    around_next = "aa",
    inside_next = "ii",
  },
  n_lines = 500,
})

require("mini.align").setup({
  mappings = {
    start = "ga",
    start_with_preview = "gA",
  },
})

require("mini.surround").setup({
  search_method = "cover_or_nearest",
  mappings = {
    add = "sa", -- Add surrounding in Normal and Visual modes
    delete = "sd", -- Delete surrounding
    find = "sf", -- Find surrounding (to the right)
    find_left = "sF", -- Find surrounding (to the left)
    highlight = "sh", -- Highlight surrounding
    replace = "sr", -- Replace surrounding
    suffix_last = "l", -- Suffix to search with "prev" method
    suffix_next = "n", -- Suffix to search with "next" method
  },
})

local miniclue = require("mini.clue")
miniclue.setup({
  triggers = {
    -- Leader triggers
    { mode = { "n", "x" }, keys = "<Leader>" },

    -- `[` and `]` keys
    { mode = "n", keys = "[" },
    { mode = "n", keys = "]" },

    -- Built-in completion
    { mode = "i", keys = "<C-x>" },

    -- `g` key
    { mode = { "n", "x" }, keys = "g" },

    -- Marks
    { mode = { "n", "x" }, keys = "'" },
    { mode = { "n", "x" }, keys = "`" },

    -- Registers
    { mode = { "n", "x" }, keys = '"' },
    { mode = { "i", "c" }, keys = "<C-r>" },

    -- Window commands
    { mode = "n", keys = "<C-w>" },

    -- `z` key
    { mode = { "n", "x" }, keys = "z" },
  },

  clues = {
    -- Enhance this by adding descriptions for <Leader> mapping groups
    miniclue.gen_clues.square_brackets(),
    miniclue.gen_clues.builtin_completion(),
    miniclue.gen_clues.g(),
    miniclue.gen_clues.marks(),
    miniclue.gen_clues.registers(),
    miniclue.gen_clues.windows(),
    miniclue.gen_clues.z(),
  },
})

require("mini.extra").setup()

-- delete
vim.keymap.set("n", "<A-q>", function()
  require("mini.bufremove").delete()
end, { desc = "Close buffer" })

-- force delete
vim.keymap.set("n", "<A-Q>", function()
  require("mini.bufremove").delete(0, true)
end, { desc = "Force close buffer" })
