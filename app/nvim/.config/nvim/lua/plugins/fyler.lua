return {
  "A7Lavinraj/fyler.nvim",
  branch = "stable",
  lazy = false,
  keys = {
    {
      "<leader>E",
      function()
        require("fyler").open({ dir = vim.fn.getcwd(), kind = "float" })
      end,
      desc = "Fyler (cwd)",
    },
    {
      "<leader>fE",
      function()
        require("fyler").open({ dir = LazyVim.root(), kind = "float" })
      end,
      desc = "Fyler (Root Dir)",
    },
  },
  opts = {
    integrations = {
      icon = "mini_icons",
    },
    views = {
      finder = {
        close_on_select = true,
        confirm_simple = false,
        default_explorer = true,
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
          ["gd"] = function(self)
            local current_node = self:cursor_node_entry()
            if not current_node then
              return
            end
            local path = current_node.path
            vim.cmd("!ripdrag --and-exit --basename --resizable --all  '" .. path .. "'")
          end,
        },
      },
    },
  },
}
