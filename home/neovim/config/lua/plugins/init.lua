-- Installed plugins load offline. Run :PackInstall explicitly to bootstrap them.
if not vim.pack then
  vim.notify("Neovim 0.12+ is required for plugins; core configuration remains available", vim.log.levels.WARN)
  return
end

vim.api.nvim_create_autocmd("PackChanged", {
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if name == "nvim-treesitter" and kind == "update" then
      if not ev.data.active then
        vim.cmd.packadd("nvim-treesitter")
      end
      vim.cmd("TSUpdate")
    end
  end,
})

local specs = {
  -- core
  "https://github.com/NMAC427/guess-indent.nvim",
  "https://github.com/nvim-treesitter/nvim-treesitter",
  "https://github.com/neovim/nvim-lspconfig",

  -- Format (./conform.lua) / Lint (./lint.lua)
  "https://github.com/stevearc/conform.nvim",
  "https://github.com/mfussenegger/nvim-lint",

  -- Debug (./debug.lua)
  "https://github.com/mfussenegger/nvim-dap",
  { src = "https://github.com/igorlfs/nvim-dap-view", version = vim.version.range("1.*") },

  -- Language-specific (../../after/ftplugin/*)
  "https://github.com/folke/lazydev.nvim",
  "https://github.com/ray-x/go.nvim",
  "https://github.com/olrtg/nvim-emmet",

  -- completion
  "https://github.com/saghen/blink.lib",
  "https://github.com/saghen/blink.cmp",
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
  "https://github.com/HawkinsT/pathfinder.nvim",
  "https://github.com/chrisgrieser/nvim-origami",
  "https://github.com/monaqa/dial.nvim",
  "https://github.com/stevearc/quicker.nvim",

  -- writing / docs
  "https://github.com/HakonHarnes/img-clip.nvim",
  "https://github.com/chomosuke/typst-preview.nvim",
  "https://github.com/MeanderingProgrammer/render-markdown.nvim",
  "https://github.com/selimacerbas/kitehost.nvim",
  "https://github.com/selimacerbas/mdkite.nvim",

  -- misc
  "https://github.com/nvim-lua/plenary.nvim",
  -- "https://github.com/wakatime/vim-wakatime",
  -- "https://github.com/iwe-org/iwe.nvim",

  -- colorscheme
  { src = "https://github.com/nvim-mini/mini.base16", version = "v0.18.0" },
}

vim.api.nvim_create_user_command("PackUpdate", function()
  -- Register specs only for this explicit operation, never during startup.
  vim.pack.add(specs, { confirm = true, load = false })
  vim.pack.update()
end, { desc = "Explicitly update vim.pack plugins (network access)" })

vim.api.nvim_create_user_command("PackInstall", function()
  local missing = {}
  for _, command in ipairs({ "git" }) do
    if vim.fn.executable(command) == 0 then
      missing[#missing + 1] = command
    end
  end
  if #missing > 0 then
    vim.notify("Plugin bootstrap prerequisites missing: " .. table.concat(missing, ", "), vim.log.levels.ERROR)
    return
  end
  vim.pack.add(specs, { confirm = true })
  vim.notify("Plugins installed. Restart Neovim, then :TSInstallBaseline for parsers.")
end, { desc = "Explicitly install vim.pack plugins (network access)" })

-- Load local runtime files directly: vim.pack.add may repair locks or fetch repositories.
local missing = {}
local plugin_dir = vim.fs.joinpath(vim.fn.stdpath("data"), "site", "pack", "core", "opt")
for _, spec in ipairs(specs) do
  local source = type(spec) == "string" and spec or spec.src
  local name = type(spec) == "table" and spec.name or nil
  name = name or source:gsub("/+$", ""):match("([^/]+)$"):gsub("%.git$", "")
  if vim.fn.isdirectory(vim.fs.joinpath(plugin_dir, name)) == 1 then
    vim.cmd.packadd({ name, bang = vim.v.vim_did_init == 0 })
  else
    missing[#missing + 1] = name
  end
end
if #missing > 0 then
  vim.schedule(function()
    vim.notify("Optional plugins missing; run :PackInstall to bootstrap. Using core editor defaults.", vim.log.levels.INFO)
  end)
  return
end

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
