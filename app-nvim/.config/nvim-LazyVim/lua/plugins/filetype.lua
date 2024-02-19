return {
  {
    "akinsho/flutter-tools.nvim",
    lazy = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "stevearc/dressing.nvim", -- optional for vim.ui.select
    },
    config = true,
  },
  {
    "tadmccorkle/markdown.nvim",
    event = "VeryLazy",
    opts = {
      mappings = false,
      on_attach = function(bufnr)
        local map = vim.keymap.set
        local opts = { buffer = bufnr }
        map({ "n", "i" }, "<M-l><M-o>", "<Cmd>MDListItemBelow<CR>", opts)
        map({ "n", "i" }, "<M-L><M-O>", "<Cmd>MDListItemAbove<CR>", opts)
        map("n", "<M-c>", "<Cmd>MDTaskToggle<CR>", opts)
        map("x", "<M-c>", ":MDTaskToggle<CR>", opts)
      end,
    },
  },
}
