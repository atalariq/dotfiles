-- Completion via blink.cmp

local cmp = require("blink.cmp")
cmp.build():wait(60000)

cmp.setup({
  appearance = { nerd_font_variant = "mono" },
  completion = {
    menu = { draw = { treesitter = { "lsp" } } },
    documentation = { auto_show = true, auto_show_delay_ms = 200 },
    ghost_text = { enabled = true },
  },
  keymap = {
    preset = "enter",
    ["<C-y>"] = { "select_and_accept" },
    ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
    ["<C-e>"] = { "hide", "fallback" },

    ["<Tab>"] = {
      function(_cmp)
        if _cmp.snippet_active() then
          return _cmp.accept()
        else
          return _cmp.select_and_accept()
        end
      end,
      "snippet_forward",
      "fallback",
    },
    ["<S-Tab>"] = { "snippet_backward", "fallback" },

    ["<Up>"] = { "select_prev", "fallback" },
    ["<Down>"] = { "select_next", "fallback" },
    ["<C-p>"] = { "select_prev", "fallback_to_mappings" },
    ["<C-n>"] = { "select_next", "fallback_to_mappings" },

    ["<C-b>"] = { "scroll_documentation_up", "fallback" },
    ["<C-f>"] = { "scroll_documentation_down", "fallback" },

    ["<C-k>"] = { "show_signature", "hide_signature", "fallback" },
  },
  sources = {
    default = { "git", "lsp", "path", "snippets", "buffer" },
    providers = {
      git = {
        module = "blink-cmp-git",
        name = "Git",
        opts = {},
      },
    },
  },
  cmdline = {
    completion = {
      list = { selection = { preselect = false } },
      menu = {
        auto_show = function(ctx)
          return vim.fn.getcmdtype() == ":"
        end,
      },
      ghost_text = { enabled = true },
    },
    keymap = {
      preset = "cmdline",
      ["<CR>"] = { "accept_and_enter", "fallback" },
      ["<C-space>"] = { "show", "fallback" },
      ["<Down>"] = { "select_next", "fallback" },
      ["<Up>"] = { "select_prev", "fallback" },
    },
  },
  fuzzy = { implementation = "rust" },
})
