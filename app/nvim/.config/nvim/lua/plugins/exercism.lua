return {
  "2kabhishek/exercism.nvim",
  cmd = { "Exercism" },
  keys = {
    { "<leader>cxl", "<Cmd>Exercism list<CR>", desc = "Exercism: List exercises" },
    { "<leader>cxt", "<Cmd>Exercism test<CR>", desc = "Exercism: run test" },
    { "<leader>cxs", "<Cmd>Exercism submit<CR>", desc = "Exercism: submit" },
    { "<leader>cxr", "<Cmd>Exercism recents<CR>", desc = "Exercism: List recents exercises" },
  },
  dependencies = {
    "2kabhishek/utils.nvim", -- required, for utility functions
    "2kabhishek/termim.nvim", -- optional, better UX for running tests
  },
  opts = {
    exercism_workspace = "~/Exercism",
    default_language = "go",
    add_default_keybindings = false,
  },
}
