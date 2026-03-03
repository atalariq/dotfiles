return {
  "A7Lavinraj/fyler.nvim",
  branch = "stable",
  lazy = false,
  keys = {
    { "<leader>F", "<Cmd>Fyler kind=float<Cr>", desc = "Open Fyler View" },
  },
  opts = {
    integrations = {
      icon = "mini_icons",
    },
    views = {
      finder = {
        close_on_select = true,
        confirm_simple = true,
        default_explorer = false,
        delete_to_trash = true,
        mappings = {
          ["q"] = "CloseView",
          ["<CR>"] = "Select",
          ["<C-t>"] = "SelectTab",
          ["|"] = "SelectVSplit",
          ["-"] = "SelectSplit",
          ["^"] = "GotoParent",
          ["["] = "GotoParent",
          ["]"] = "GotoCwd",
          ["="] = "GotoCwd",
          ["."] = "GotoNode",
          ["#"] = "CollapseAll",
          ["<BS>"] = "CollapseNode",
        },
      },
    },
  },
}
