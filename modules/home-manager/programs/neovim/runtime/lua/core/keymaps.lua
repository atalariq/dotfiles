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

-- Parity port from legacy config (2026-10): behavior, not exact keys.
local function bufnext()
  vim.cmd.bnext()
end
local function bufprev()
  vim.cmd.bprevious()
end
map("i", "jk", "<Esc>", { desc = "Normal mode" })
map("i", "kj", "<Esc>", { desc = "Normal mode" })
map("n", "<C-s>", "<cmd>update<cr>", { desc = "Save" })
map("i", "<C-s>", "<Esc><cmd>update<cr>", { desc = "Save" })
map("n", "<Tab>", bufnext, { desc = "Next buffer" })
map("n", "<S-Tab>", bufprev, { desc = "Previous buffer" })
map("n", "Y", "y$", { desc = "Yank to EOL" })
map("v", "<", "<gv")
map("v", ">", ">gv")
map("n", "J", "mzJ`z", { desc = "Join keeping cursor" })
map("n", "<C-u>", "<C-u>zz", { expr = true, desc = "Half-page up, centered" })
map("n", "<C-d>", "<C-d>zz", { expr = true, desc = "Half-page down, centered" })
map("n", "n", "nzzzv", { desc = "Next search, centered" })
map("n", "N", "Nzzzv", { desc = "Prev search, centered" })
map("n", "<C-h>", "<C-w>h", { desc = "Window left" })
map("n", "<C-j>", "<C-w>j", { desc = "Window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window up" })
map("n", "<C-l>", "<C-w>l", { desc = "Window right" })
map("n", "<leader>uw", "<cmd>set wrap!<cr>", { desc = "Toggle wrap" })
map(
  "n",
  "<leader>cd",
  function()
    local root = vim.fs.root(0, { ".git", "package.json", "Cargo.toml", "go.mod", "pyproject.toml" })
    vim.cmd.cd(root or vim.fn.expand("%:p:h"))
  end,
  { desc = "Cd to project root" }
)
-- DAP (nvim-dap): F5/F10/F11/F9 per community set; DapView on demand.
map("n", "<F5>", function()
  require("dap").continue()
end, { desc = "DAP continue" })
map("n", "<F10>", function()
  require("dap").step_over()
end, { desc = "DAP step over" })
map("n", "<F11>", function()
  require("dap").step_into()
end, { desc = "DAP step into" })
map("n", "<S-F11>", function()
  require("dap").step_out()
end, { desc = "DAP step out" })
map("n", "<F9>", function()
  require("dap").toggle_breakpoint()
end, { desc = "DAP breakpoint" })
map("n", "<leader>do", "<cmd>DapViewToggle<cr>", { desc = "DAP view" })
