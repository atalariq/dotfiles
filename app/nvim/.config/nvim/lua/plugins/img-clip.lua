return {
  "HakonHarnes/img-clip.nvim",
  event = "VeryLazy",
  opts = {
    default = {
      relative_to_current_file = false,
      dir_path = "assets",
      prompt_for_file_name = true,
      show_dir_path_in_prompt = false,
    },
    filetypes = {
      typst = {
        template = [[#img("$FILE_PATH", caption: [$CURSOR])]],
      },
    },
  },
  keys = {
    -- suggested keymap
    { "<leader>p", "<cmd>PasteImage<cr>", desc = "Paste image from system clipboard" },
  },
}
