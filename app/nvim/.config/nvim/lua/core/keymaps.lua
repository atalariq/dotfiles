-- core keymaps

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- better escape: jk / kj in insert mode
map("i", "jk", "<Esc>", opts)
map("i", "kj", "<Esc>", opts)

-- clear search highlight
map("n", "<Esc>", "<cmd>nohlsearch<CR>", opts)

-- save file
map("n", "<C-s>", "<cmd>update<CR>", opts)
map({ "i", "v" }, "<C-s>", "<esc><cmd>update<CR>", opts)

-- source current file
map("n", "<leader>fs", "<cmd>source %<CR>", { desc = "Source file" })

-- better undo / redo
map("n", "u", "<cmd>undo<CR>", opts)
map("n", "U", "<cmd>redo<CR>", opts)

-- yank to end of line
map("n", "Y", "y$", { desc = "Yank to end of line" })

-- keep selection indented
map("v", "<", "<gv", opts)
map("v", ">", ">gv", opts)

-- window navigation
map("n", "<C-h>", "<C-w>h", opts)
map("n", "<C-j>", "<C-w>j", opts)
map("n", "<C-k>", "<C-w>k", opts)
map("n", "<C-l>", "<C-w>l", opts)

-- buffer navigation
map("n", "<Tab>", "<cmd>bn<CR>", opts)
map("n", "<S-Tab>", "<cmd>bp<CR>", opts)

-- close buffer safely
map("n", "<A-q>", function()
  if vim.bo.modified then
    print("Save the file first!")
  else
    local bufnr = vim.api.nvim_get_current_buf()
    vim.cmd("bp")
    vim.cmd("bd" .. bufnr)
  end
end, { desc = "Close buffer" })

-- keep cursor position when joining lines
map("n", "J", "mzJ`z", opts)

-- quickfix navigation
map("n", "]q", "<cmd>cnext<CR>", opts)
map("n", "[q", "<cmd>cprev<CR>", opts)

-- lsp keymaps (buffer-local via LspAttach)
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("user_lsp_keymaps", { clear = true }),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)

    map("n", "grd", vim.lsp.buf.definition, { buffer = args.buf, silent = true, desc = "Go to definition" })
    map("n", "gri", vim.lsp.buf.implementation, { buffer = args.buf, silent = true, desc = "Go to implementation" })
    map("n", "grr", vim.lsp.buf.references, { buffer = args.buf, silent = true, desc = "References" })
    map("n", "K", vim.lsp.buf.hover, { buffer = args.buf, silent = true, desc = "Hover" })
    map("n", "<C-k>", vim.lsp.buf.signature_help, { buffer = args.buf, silent = true, desc = "Signature help" })
    map("n", "<leader>cf", vim.lsp.buf.format, { buffer = args.buf, silent = true, desc = "Format" })
    map("n", "<leader>cr", vim.lsp.buf.rename, { buffer = args.buf, silent = true, desc = "Rename" })
    map("n", "<leader>ca", vim.lsp.buf.code_action, { buffer = args.buf, silent = true, desc = "Code action" })
    if client and client:supports_method("textDocument/inlayHint", args.buf) then
      map("n", "<leader>th", function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = args.buf }))
      end, { buffer = args.buf, silent = true, desc = "[T]oggle Inlay [H]ints" })
    end
  end,
})

-- fuzzy finder keymaps (fzf-lua, lazy-required)
map("n", "<leader><leader>", function()
  require("fzf-lua").buffers()
end, { desc = "Buffers" })
map("n", "<leader>sc", function()
  require("fzf-lua").files({ cwd = "~/.config" })
end, { desc = "Edit configs" })
map("n", "<leader>sD", function()
  require("fzf-lua").diagnostics_workspace()
end, { desc = "Workspace diagnostics" })
map("n", "<leader>sd", function()
  require("fzf-lua").diagnostics_document()
end, { desc = "Document diagnostics" })
map("n", "<leader>sf", function()
  require("fzf-lua").files()
end, { desc = "Find files" })
map("n", "<leader>sg", function()
  require("fzf-lua").live_grep()
end, { desc = "Live grep" })
map("n", "<leader>sh", function()
  require("fzf-lua").help_tags()
end, { desc = "Help tags" })
map("n", "<leader>sk", function()
  require("fzf-lua").keymaps()
end, { desc = "Keymaps" })
map("n", "<leader>so", function()
  require("fzf-lua").oldfiles()
end, { desc = "Oldfiles/history" })
map("n", "<leader>sp", function()
  require("fzf-lua").builtin()
end, { desc = "Search pickers" })
map("n", "<leader>sr", function()
  require("fzf-lua").resume()
end, { desc = "Resume last search" })
map("n", "<leader>st", function()
  require("fzf-lua").tags_live_grep()
end, { desc = "Tags project (live grep)" })
map("n", "<leader>sw", function()
  require("fzf-lua").grep_cword()
end, { desc = "Grep word under cursor" })
map("n", "<leader>sz", function()
  require("fzf-lua").zoxide()
end, { desc = "Zoxide" })

-- file explorer (oil.nvim)
map("n", "<leader>e", "<cmd>Oil<CR>", { desc = "File explorer (oil)" })

-- code runner
map("n", "<leader>re", "<cmd>RunCode<CR>", { desc = "Run and execute" })
map("n", "<leader>rf", "<cmd>RunFile tab<CR>", { desc = "Run file" })
map("n", "<leader>rp", "<cmd>RunProject<CR>", { desc = "Run project" })
map("n", "<leader>rc", "<cmd>RunClose<CR>", { desc = "Run close" })

-- img-clip
map("n", "<leader>p", "<cmd>PasteImage<CR>", { desc = "Paste image from clipboard" })

-- typst preview
map("n", "<leader>ttp", "<cmd>TypstPreviewToggle<CR>", { desc = "Toggle typst preview" })

-- markdown preview
map("n", "<leader>tlp", "<cmd>LivePreview<CR>", { desc = "Toggle Live Preview markdown/html/asciidoc" })

-- conform
map({ "n", "v" }, "<leader>ff", function()
  require("conform").format({ async = true })
end, { desc = "Format buffer" })
map("n", "<leader>tf", "<cmd>FormatToggle<CR>", { desc = "Toggle format-on-save" })
