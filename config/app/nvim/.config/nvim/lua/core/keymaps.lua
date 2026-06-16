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

-- navigate visual lines
map("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true })
map("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true })

-- split navigation
map("n", "<C-h>", "<C-w>h", opts)
map("n", "<C-j>", "<C-w>j", opts)
map("n", "<C-k>", "<C-w>k", opts)
map("n", "<C-l>", "<C-w>l", opts)

-- quickfix navigation
map("n", "]q", "<cmd>cnext<CR>", { desc = "Next quickfix" })
map("n", "[q", "<cmd>cprev<CR>", { desc = "Prev quickfix" })

-- new buffer / split
map("n", "<leader>bn", "<cmd>enew<CR>", { desc = "New buffer" })
map("n", "<leader>bv", "<cmd>vsplit<CR>", { desc = "Vertical split" })

-- buffer navigation
map("n", "<Tab>", "<cmd>bn<CR>", opts)
map("n", "<S-Tab>", "<cmd>bp<CR>", opts)

-- keep cursor position when joining lines
map("n", "J", "mzJ`z", opts)

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
    map("n", "<leader>cr", vim.lsp.buf.rename, { buffer = args.buf, silent = true, desc = "Rename" })
    map("n", "<leader>ca", vim.lsp.buf.code_action, { buffer = args.buf, silent = true, desc = "Code action" })
    if client and client:supports_method("textDocument/inlayHint", args.buf) then
      map("n", "<leader>th", function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = args.buf }))
      end, { buffer = args.buf, silent = true, desc = "[T]oggle Inlay [H]ints" })
    end
  end,
})

-- cd to project root of the current file (markers), fallback to file dir
map("n", "<leader>cd", function()
  local markers = { ".git", ".hg", ".svn", "Makefile", "package.json", "Cargo.toml", "go.mod", "pyproject.toml", ".luarc.json" }
  local root = vim.fs.root(0, markers)
  if not root then
    local fname = vim.api.nvim_buf_get_name(0)
    root = fname ~= "" and vim.fs.dirname(fname) or vim.uv.cwd()
  end
  vim.cmd.cd(vim.fn.fnameescape(root))
  vim.notify("cwd → " .. root)
end, { desc = "cd to project root" })
