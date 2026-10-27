-- Nix: modules/20-plugins.nix (plugin availability), modules/10-ui.nix (mini UI plugins)
-- nvf owns plugin sources and parser builds. Keep Lua for the established
-- keymaps and plugin behaviour; startup never installs or updates software.
-- load plugin configs
require("plugins.treesitter")
require("plugins.lsp")
require("plugins.conform")
require("plugins.lint")
require("plugins.debug")
require("plugins.gitsigns")
require("plugins.fzf")
require("plugins.mini")
require("plugins.cmp")

-- Fyler clears netrw's group even when netrw has not loaded yet.
vim.api.nvim_create_augroup("FileExplorer", { clear = false })

-- --- fyler.nvim ---------------------------------
require("fyler").setup({
  hooks = {},
  integrations = { icon = vim.g.have_nerd_font and "mini_icons", winpick = { provider = "none", opts = {} } },
  views = {
    finder = {
      close_on_select = true,
      confirm_simple = true,
      default_explorer = true,
      delete_to_trash = true,
      mappings = {
        ["q"] = "CloseView",
        ["<CR>"] = "Select",
        ["<C-t>"] = "SelectTab",
        ["|"] = "SelectVSplit",
        ["-"] = "SelectSplit",
        ["^"] = "GotoParent",
        ["="] = "GotoCwd",
        ["."] = "GotoNode",
        ["#"] = "CollapseAll",
        ["<BS>"] = "CollapseNode",
      },
    },
  },
})

-- vim.opt.autochdir = true
vim.keymap.set("n", "<leader>e", "<cmd>Fyler<cr>", { desc = "Open Fyler View" })
vim.keymap.set("n", "<leader>E", "<cmd>cd %:p:h<cr><cmd>Fyler<cr>", { desc = "Open Fyler View" })

-- --- img-clip --------------------------------------------
require("img-clip").setup({
  default = {
    relative_to_current_file = true,
    dir_path = "assets",
    prompt_for_file_name = true,
    show_dir_path_in_prompt = true,
  },
  filetypes = {
    typst = {
      template = [[#image("$FILE_PATH")]],
    },
  },
})

vim.keymap.set("n", "<leader>p", "<cmd>PasteImage<CR>", { desc = "Paste image from clipboard" })

-- --- dial ------------------------------------------------
local augend = require("dial.augend")
require("dial.config").augends:register_group({
  -- default augends used when no group name is specified
  default = {
    augend.integer.alias.decimal_int,
    augend.integer.alias.hex,
    augend.date.alias["%Y/%m/%d"],
    augend.date.alias["%Y-%m-%d"],
    augend.constant.alias.en_weekday,
    augend.constant.alias.en_weekday_full,
    augend.constant.alias.bool,
    augend.constant.alias.Bool,
    augend.semver.alias.semver,
  },
})

vim.keymap.set("n", "<C-a>", function()
  require("dial.map").manipulate("increment", "normal")
end)
vim.keymap.set("n", "<C-x>", function()
  require("dial.map").manipulate("decrement", "normal")
end)
vim.keymap.set("n", "g<C-a>", function()
  require("dial.map").manipulate("increment", "gnormal")
end)
vim.keymap.set("n", "g<C-x>", function()
  require("dial.map").manipulate("decrement", "gnormal")
end)
vim.keymap.set("x", "<C-a>", function()
  require("dial.map").manipulate("increment", "visual")
end)
vim.keymap.set("x", "<C-x>", function()
  require("dial.map").manipulate("decrement", "visual")
end)
vim.keymap.set("x", "g<C-a>", function()
  require("dial.map").manipulate("increment", "gvisual")
end)
vim.keymap.set("x", "g<C-x>", function()
  require("dial.map").manipulate("decrement", "gvisual")
end)

-- --- quicker ------------------------------------

vim.keymap.set("n", "<leader>q", function()
  require("quicker").toggle()
end, { desc = "Toggle quickfix" })
vim.keymap.set("n", "<leader>l", function()
  require("quicker").toggle({ loclist = true })
end, { desc = "Toggle loclist" })

require("quicker").setup({
  keys = {
    {
      ">",
      function()
        require("quicker").expand({ before = 2, after = 2, add_to_existing = true })
      end,
      desc = "Expand quickfix context",
    },
    {
      "<",
      function()
        require("quicker").collapse()
      end,
      desc = "Collapse quickfix context",
    },
  },
})

-- --- zero-config setup --------------------------
require("guess-indent").setup()
require("blink.indent").setup()
require("colorizer").setup()
require("nvim-autopairs").setup()
require("nvim-ts-autotag").setup()
require("origami").setup()
require("pathfinder").setup()
