--[[
Plugin setup via vim.pack (Neovim's built-in package manager).

vim.pack.add() registers a plugin source and installs it if missing.
vim.pack.update() refreshes all registered plugins to latest HEAD.
]]

local pack = vim.pack

local function run_build(name, cmd, cwd)
  local result = vim.system(cmd, { cwd = cwd }):wait()
  if result.code ~= 0 then
    local stderr = result.stderr or ""
    local stdout = result.stdout or ""
    local output = stderr ~= "" and stderr or stdout
    if output == "" then
      output = "No output from build command."
    end
    vim.notify(("Build failed for %s:\n%s"):format(name, output), vim.log.levels.ERROR)
  end
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

    if name == "peek.nvim" and vim.fn.executable("deno") == 1 then
      run_build(name, { "deno", "task", "--quiet", "build:fast" }, ev.data.path)
      return
    end
  end,
})

-- core plugins
pack.add({ "https://github.com/nvim-treesitter/nvim-treesitter" }, { confirm = false })
pack.add({ "https://github.com/NMAC427/guess-indent.nvim" }, { confirm = false })
pack.add({ "https://github.com/lukas-reineke/indent-blankline.nvim" }, { confirm = false })

-- LSP, formatter, and linter
pack.add({ "https://github.com/neovim/nvim-lspconfig" }, { confirm = false })
pack.add({ "https://github.com/mason-org/mason.nvim" }, { confirm = false })
pack.add({ "https://github.com/mason-org/mason-lspconfig.nvim" }, { confirm = false })
pack.add({ "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim" }, { confirm = false })
pack.add({ "https://github.com/stevearc/conform.nvim" }, { confirm = false })
pack.add({ "https://github.com/mfussenegger/nvim-lint" }, { confirm = false })
pack.add({ "https://github.com/mfussenegger/nvim-dap" }, { confirm = false })

-- completion with blink.cmp
pack.add({ "https://github.com/saghen/blink.lib" }, { confirm = false })
pack.add({ "https://github.com/saghen/blink.cmp" }, { confirm = false })
pack.add({ "https://github.com/Kaiser-Yang/blink-cmp-git" }, { confirm = false })
pack.add({ "https://github.com/rafamadriz/friendly-snippets" }, { confirm = false })
pack.add({ "https://github.com/windwp/nvim-autopairs" }, { confirm = false })
pack.add({ "https://github.com/windwp/nvim-ts-autotag" }, { confirm = false })

-- fuzzy finder
pack.add({ "https://github.com/nvim-lua/plenary.nvim" }, { confirm = false })
pack.add({ "https://github.com/ibhagwan/fzf-lua" }, { confirm = false })

-- mini.nvim ecosystem
pack.add({
  { src = "https://github.com/echasnovski/mini.icons", version = "main" },
  { src = "https://github.com/echasnovski/mini.extra", version = "main" },
  { src = "https://github.com/echasnovski/mini.statusline", version = "main" },
  { src = "https://github.com/echasnovski/mini.tabline", version = "main" },
  { src = "https://github.com/echasnovski/mini.surround", version = "main" },
  { src = "https://github.com/echasnovski/mini.align", version = "main" },
  { src = "https://github.com/echasnovski/mini.ai", version = "main" },
  { src = "https://github.com/echasnovski/mini.cursorword", version = "main" },
  { src = "https://github.com/echasnovski/mini.move", version = "main" },
  { src = "https://github.com/echasnovski/mini.splitjoin", version = "main" },
  { src = "https://github.com/echasnovski/mini.diff", version = "main" },
  { src = "https://github.com/echasnovski/mini-git", version = "main" },
  { src = "https://github.com/echasnovski/mini.clue", version = "main" },
}, { confirm = false })

-- editor utilities
pack.add({ "https://github.com/stevearc/oil.nvim" }, { confirm = false })
pack.add({ "https://github.com/HakonHarnes/img-clip.nvim" }, { confirm = false })
pack.add({ "https://github.com/catgoose/nvim-colorizer.lua" }, { confirm = false })

-- language-specific
pack.add({ "https://github.com/chomosuke/typst-preview.nvim" }, { confirm = false })
pack.add({ "https://github.com/toppair/peek.nvim" }, { confirm = false })
pack.add({ "https://github.com/MeanderingProgrammer/render-markdown.nvim" }, { confirm = false })

pack.add({ "https://github.com/selimacerbas/live-server.nvim" }, { confirm = false })
pack.add({ "https://github.com/selimacerbas/markdown-preview.nvim" }, { confirm = false })

-- misc
pack.add({ "https://github.com/wakatime/vim-wakatime" }, { confirm = false })

-- colorscheme (neanias fork with transparent support)
pack.add({ { src = "https://github.com/neanias/everforest-nvim", name = "everforest" } }, { confirm = false })

-- ensure all plugins are installed (first run) or up-to-date
-- pack.update()

-- load plugin configs
require("plugins.treesitter")

require("guess-indent").setup()
require("ibl").setup()
require("nvim-autopairs").setup()
require("nvim-ts-autotag").setup()
require("plugins.lsp")
require("plugins.dap")
require("plugins.cmp")

require("plugins.mini")

require("fzf-lua").setup({
  "default",
})

require("oil").setup({
  default_file_explorer = true,
  view_options = { show_hidden = true },
})

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

require("render-markdown").setup({
  render_modes = { "n", "c" }, -- nonaktif saat insert
  anti_conceal = {
    enabled = true,
  },
})

require("peek").setup({
  auto_load = true, -- whether to automatically load preview when entering another markdown buffer
  close_on_bdelete = true, -- close preview window on buffer delete
  syntax = true, -- enable syntax highlighting, affects performance
  theme = "light", -- 'dark' or 'light'
  update_on_change = true,
  -- app = "webview", -- 'webview', 'browser', string or a table of strings explained below
  app = "brave", -- 'webview', 'browser', string or a table of strings explained below
  filetype = { "markdown" }, -- list of filetypes to recognize as markdown relevant if update_on_change is true
  throttle_at = 200000, -- start throttling when file exceeds this amount of bytes in size
  throttle_time = "auto", -- minimum amount of time in milliseconds that has to pass before starting new render
})

vim.api.nvim_create_user_command("PeekOpen", require("peek").open, {})
vim.api.nvim_create_user_command("PeekClose", require("peek").close, {})

require("colorizer").setup()

require("live_server").setup()
require("markdown_preview").setup({
  instance_mode = "takeover", -- "takeover" (one tab) or "multi" (tab per instance)
  port = 0, -- 0 = auto (8421 for takeover, OS-assigned for multi)
  open_browser = true,
  default_theme = "dark", -- "dark" or "light"; initial preview theme
  debounce_ms = 300,
})
