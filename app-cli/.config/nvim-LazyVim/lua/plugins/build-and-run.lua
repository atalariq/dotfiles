local options = { noremap = true, silent = true }

return {
  {
    "CRAG666/code_runner.nvim",
    lazy = true,
    dependencies = "nvim-lua/plenary.nvim",
    keys = {
      { "<leader>re", "<CMD>RunCode<CR>", options, desc = "Run and Execute" },
      { "<leader>rf", "<CMD>RunFile tab<CR>", options, desc = "Run File (int tab)" },
      { "<leader>rp", "<CMD>RunProject<CR>", options, desc = "Run Project" },
      { "<leader>rc", "<CMD>RunClose<CR>", options, desc = "Run Close" },
    },
    config = function()
      require("code_runner").setup({
        focus = true,
        startinsert = true,
        term = {
          position = "vertical",
          size = 45,
        },
        filetype = {
          c = {
            'cd "$dir" &&',
            'mkdir -p "$dir/bin" &&',
            'gcc "$fileName" -o "$dir/bin/$fileNameWithoutExt" &&',
            '"$dir/bin/$fileNameWithoutExt"',
          },
          cpp = {
            'cd "$dir" &&',
            'mkdir -p "$dir/bin" &&',
            'g++ -Wall -Wextra -O2 "$fileName" -o "$dir/bin/$fileNameWithoutExt" &&',
            '"$dir/bin/$fileNameWithoutExt"',
          },
          dart = {
            'dart run "$fileName"'
          }
        },
      })
    end,
  },
}
