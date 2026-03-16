return {
  {
    "snacks.nvim",
    keys = {
      -- Override default keymaps to switch behavior
      {
        "<leader>e",
        function()
          Snacks.explorer({ cwd = vim.fn.getcwd() })
        end,
        desc = "Explorer Snacks (cwd)",
      },
      {
        "<leader>fe",
        function()
          Snacks.explorer({ cwd = LazyVim.root() })
        end,
        desc = "Explorer Snacks (Root Dir)",
      },
    },
    opts = {
      picker = {
        sources = {
          explorer = {
            layout = { layout = { position = "left" } },
            hidden = true,
            win = {
              list = {
                keys = {
                  ["y"] = "yank_relative_cwd",
                  ["Y"] = "yank_relative_home",
                  ["gd"] = "drop",
                  ["gD"] = "drag",
                },
              },
            },
            actions = {
              drop = function(_, item)
                vim.notify("Drop file: " .. item.file)
                vim.cmd("!ripdrag --and-exit --basename --resizable --all '".. item.file .. "'")
              end,
              drag = function(_, _)
                vim.cmd("!ripdrag --and-exit --basename --resizable --all --target --keep ")
              end,
              yank_relative_cwd = function(_, item)
                local path = vim.fn.fnamemodify(item.file, ":.")
                vim.fn.setreg("+", path)
                vim.fn.setreg('"', path)
                vim.notify("Yanked: " .. path)
              end,
              yank_relative_home = function(_, item)
                local path = vim.fn.fnamemodify(item.file, ":~")
                vim.fn.setreg("+", path)
                vim.fn.setreg('"', path)
                vim.notify("Yanked: " .. path)
              end,
            },
          },
        },
      },
    },
  },
}
