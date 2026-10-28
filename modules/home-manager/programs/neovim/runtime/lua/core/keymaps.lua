-- Keymaps that belong to this configuration rather than to a plugin preset.
local map = vim.keymap.set

-- nvf ships fzf-lua with no keymaps, so the pickers are ours.
local function picker(name)
  return function()
    require("fzf-lua")[name]()
  end
end

map("n", "<leader>ff", picker("files"), { desc = "Find files" })
map("n", "<leader>fg", picker("live_grep"), { desc = "Live grep" })
map("n", "<leader>fw", picker("grep_cword"), { desc = "Grep word under cursor" })
map("n", "<leader>fb", picker("buffers"), { desc = "Buffers" })
map("n", "<leader>fh", picker("help_tags"), { desc = "Help tags" })
map("n", "<leader>fd", picker("diagnostics_document"), { desc = "Document diagnostics" })
map("n", "<leader>gc", picker("git_commits"), { desc = "Git commits" })
map("n", "<leader>gs", picker("git_status"), { desc = "Git status" })

-- Quick editing.
map("n", "<leader>w", "<cmd>write<cr>", { desc = "Save" })
map("n", "<leader>q", "<cmd>quit<cr>", { desc = "Quit" })

-- These plugins are lazy-loaded on the very command the mapping runs.
map("n", "<leader>e", "<cmd>Oil<cr>", { desc = "File explorer" })
map("n", "<leader>ud", "<cmd>Undotree<cr>", { desc = "Undo history" })
map("n", "<leader>sr", "<cmd>GrugFar<cr>", { desc = "Search and replace" })
