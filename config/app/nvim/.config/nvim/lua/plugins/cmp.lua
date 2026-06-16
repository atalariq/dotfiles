-- Completion via blink.cmp

local cmp = require("blink.cmp")

cmp.setup({
  appearance = { nerd_font_variant = "mono" },
  fuzzy = { implementation = "prefer_rust" },
  signature = { enabled = true },
  completion = {
    -- accept = { auto_brackets = { enabled = true } },
    menu = { draw = { treesitter = { "lsp" } } },
    documentation = { auto_show = true, auto_show_delay_ms = 200 },
    ghost_text = { enabled = true },
    list = {
      selection = {
        preselect = function(ctx)
          return not require("blink.cmp").snippet_active({ direction = 1 })
        end,
      },
    },
  },
  sources = {
    default = { "git", "lazydev", "lsp", "path", "snippets", "buffer" },
    providers = {
      lazydev = {
        name = "LazyDev",
        module = "lazydev.integrations.blink",
        score_offset = 100,
      },
      git = {
        module = "blink-cmp-git",
        name = "Git",
        opts = {},
      },
    },
  },
  keymap = {
    preset = "default",
    ["<CR>"] = { "accept", "fallback" },

    ["<Tab>"] = {
      require("blink.cmp.keymap.presets").get("super-tab")["<Tab>"][1],
      "snippet_forward",
      "fallback",
    },
  },
  cmdline = {
    completion = {
      list = { selection = { preselect = false } },
      menu = {
        auto_show = function(ctx)
          -- return vim.fn.getcmdtype() == ":"
          return vim.fn.getcmdtype() ~= ":" or not vim.fn.getcmdline():match("^[%%0-9,'<>%-]*!")
        end,
      },
      ghost_text = { enabled = true },
    },
    keymap = {
      preset = "cmdline",
      ["<CR>"] = { "accept_and_enter", "fallback" },
      ["<Down>"] = { "select_next", "fallback" },
      ["<Up>"] = { "select_prev", "fallback" },
      ["<Right>"] = false,
      ["<Left>"] = false,
    },
  },
})
