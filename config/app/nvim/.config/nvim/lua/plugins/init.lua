--[[
Plugin setup via vim.pack (Neovim's built-in package manager).

vim.pack.add() registers a plugin source and installs it if missing.
vim.pack.update() refreshes all registered plugins to latest HEAD.
]]

-- local function run_build(name, cmd, cwd)
--   local result = vim.system(cmd, { cwd = cwd }):wait()
--   if result.code ~= 0 then
--     local stderr = result.stderr or ""
--     local stdout = result.stdout or ""
--     local output = stderr ~= "" and stderr or stdout
--     if output == "" then
--       output = "No output from build command."
--     end
--     vim.notify(("Build failed for %s:\n%s"):format(name, output), vim.log.levels.ERROR)
--   end
-- end

vim.api.nvim_create_autocmd("PackChanged", {
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if name == "nvim-treesitter" and kind == "install" then
      if not ev.data.active then
        vim.cmd.packadd("nvim-treesitter")
      end
      -- Ensure basic parsers are installed
      local parsers = {
        "bash",
        "diff",
        "ini",
        "lua",
        "luadoc",
        "markdown",
        "markdown_inline",
        "query",
        "vim",
        "vimdoc",
      }

      require("nvim-treesitter").install(parsers):wait(60000)
    end
    if name == "nvim-treesitter" and kind == "update" then
      if not ev.data.active then
        vim.cmd.packadd("nvim-treesitter")
      end
      vim.cmd("TSUpdate")
    end

    if name == "blink-cmp" and (kind == "install" or kind == "update") then
      if not ev.data.active then
        vim.cmd.packadd("blink-cmp")
      end
      require("blink-cmp").build():wait(60000)
    end

    -- if name == "<plugin-name>" and vim.fn.executable("<executable>") == 1 then
    --   run_build(name, { "<cmd>", "<args>" }, ev.data.path)
    --   return
    -- end
  end,
})

vim.pack.add({
  -- core
  "https://github.com/nvim-treesitter/nvim-treesitter",
  "https://github.com/NMAC427/guess-indent.nvim",

  -- LSP / format / lint / dap
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/stevearc/conform.nvim",
  "https://github.com/mfussenegger/nvim-lint",
  "https://github.com/mfussenegger/nvim-dap",
  { src = "https://github.com/igorlfs/nvim-dap-view", version = vim.version.range("1.*") },

  -- Language-specific
  "https://github.com/folke/lazydev.nvim",
  "https://github.com/ray-x/go.nvim",

  -- completion
  "https://github.com/saghen/blink.cmp",
  "https://github.com/saghen/blink.lib",
  "https://github.com/rafamadriz/friendly-snippets",
  "https://github.com/Kaiser-Yang/blink-cmp-git",

  "https://github.com/windwp/nvim-autopairs",
  "https://github.com/windwp/nvim-ts-autotag",

  -- finder / files
  "https://github.com/ibhagwan/fzf-lua",
  "https://github.com/A7Lavinraj/fyler.nvim",

  -- mini (related: ./mini.lua)
  { src = "https://github.com/nvim-mini/mini.ai", version = "main" },
  { src = "https://github.com/nvim-mini/mini.align", version = "main" },
  { src = "https://github.com/nvim-mini/mini.bracketed", version = "main" },
  { src = "https://github.com/nvim-mini/mini.bufremove", version = "main" },
  { src = "https://github.com/nvim-mini/mini.clue", version = "main" },
  { src = "https://github.com/nvim-mini/mini.cursorword", version = "main" },
  { src = "https://github.com/nvim-mini/mini.extra", version = "main" },
  { src = "https://github.com/nvim-mini/mini.hipatterns", version = "main" },
  { src = "https://github.com/nvim-mini/mini.icons", version = "main" },
  { src = "https://github.com/nvim-mini/mini.input", version = "main" },
  { src = "https://github.com/nvim-mini/mini.jump", version = "main" },
  { src = "https://github.com/nvim-mini/mini.jump2d", version = "main" },
  { src = "https://github.com/nvim-mini/mini.move", version = "main" },
  { src = "https://github.com/nvim-mini/mini.splitjoin", version = "main" },
  { src = "https://github.com/nvim-mini/mini.statusline", version = "main" },
  { src = "https://github.com/nvim-mini/mini.surround", version = "main" },
  { src = "https://github.com/nvim-mini/mini.tabline", version = "main" },

  -- git
  "https://github.com/lewis6991/gitsigns.nvim",
  "https://github.com/tpope/vim-fugitive",

  -- QoL
  "https://github.com/folke/trouble.nvim",
  "https://github.com/saghen/blink.indent",
  "https://github.com/catgoose/nvim-colorizer.lua",
  "https://github.com/stevearc/quicker.nvim",
  "https://github.com/HawkinsT/pathfinder.nvim",
  "https://github.com/chrisgrieser/nvim-origami",
  "https://github.com/monaqa/dial.nvim",

  -- writing / docs
  "https://github.com/HakonHarnes/img-clip.nvim",
  "https://github.com/chomosuke/typst-preview.nvim",
  "https://github.com/MeanderingProgrammer/render-markdown.nvim",
  "https://github.com/selimacerbas/live-server.nvim",
  "https://github.com/selimacerbas/markdown-preview.nvim",

  -- misc
  "https://github.com/nvim-lua/plenary.nvim",
  "https://github.com/wakatime/vim-wakatime",
  "https://github.com/iwe-org/iwe.nvim",

  -- colorscheme
  { src = "https://github.com/neanias/everforest-nvim", name = "everforest" },
}, { confirm = false })

-- ensure all plugins are installed (first run) or up-to-date
-- pack.update()

-- load plugin configs
require("plugins.treesitter")
require("plugins.lsp")
require("plugins.conform")
require("plugins.lint")
require("plugins.dap")
require("plugins.gitsigns")
require("plugins.fzf")
require("plugins.mini")
require("plugins.cmp")

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
      template = [[#img("$FILE_PATH", caption: [$CURSOR])]],
    },
  },
})

vim.keymap.set("n", "<leader>p", "<cmd>PasteImage<CR>", { desc = "Paste image from clipboard" })

-- --- quicker ---------------------------------------------
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

vim.keymap.set("n", "<leader>q", function()
  require("quicker").toggle()
end, { desc = "Toggle quickfix" })
vim.keymap.set("n", "<leader>l", function()
  require("quicker").toggle({ loclist = true })
end, { desc = "Toggle loclist" })

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

-- --- typst-preview ---------------------------------------
require("typst-preview").setup({
  debug = false,
  -- open_cmd = "/opt/brave-bin/brave --app=%s --profile-directory=Default --app-id=previewer",
  invert_colors = "never",
  follow_cursor = true,
  dependencies_bin = {
    tinymist = "/usr/bin/tinymist",
    websocat = "/usr/bin/websocat",
  },
})

vim.keymap.set("n", "<leader>ttp", "<cmd>TypstPreviewToggle<CR>", { desc = "Toggle typst preview" })
-- --- zero-config setup --------------------------
require("guess-indent").setup()
require("blink.indent").setup()
require("colorizer").setup()
require("live_server").setup()
require("nvim-autopairs").setup()
require("nvim-ts-autotag").setup()
require("origami").setup()
require("pathfinder").setup()
