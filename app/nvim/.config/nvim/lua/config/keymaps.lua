-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local get_mapper = function(mode, noremap)
  return function(lhs, rhs, opts)
    opts = opts or {}
    opts.noremap = noremap
    vim.keymap.set(mode, lhs, rhs, opts)
  end
end

local noremap = get_mapper("", true)
local nnoremap = get_mapper("n", true)
local inoremap = get_mapper("i", true)
local vnoremap = get_mapper("v", true)
local cnoremap = get_mapper("c", true)

-- Files {{{
-- Save file
nnoremap("<C-s>", "<Cmd>update<cr>", { desc = "Save File" })
inoremap("<C-s>", "<Esc><Esc><Cmd>update<cr>", { desc = "Save File" })
vnoremap("<C-s>", "<Esc><Esc><Cmd>update<cr>", { desc = "Save File" })

-- Source file
-- nnoremap("<leader>fs", "<CMD>source % | echo 'Source current file!'<CR>", { desc = "File: source current" })

nnoremap("<Leader>cd", "<Cmd>cd %:h<CR>", { desc = "Change directory" })

-- }}}

-- Search {{{
nnoremap("/", "ms/", { desc = "Keeps jumplist after forward searching" })
nnoremap("?", "ms?", { desc = "Keeps jumplist after backward searching" })
nnoremap("<Esc><Esc>", "<CMD>nohl<CR>", { desc = "Toggle search highlight" })
nnoremap("<M-n>", "<CMD>nohl<CR>", { desc = "Toggle search highlight" })

-- }}}

-- Windows {{{
nnoremap("<C-k>", "<C-w><C-k>", { desc = "Go to the top window" })
nnoremap("<C-j>", "<C-w><C-j>", { desc = "Go to the bottom window" })
nnoremap("<C-l>", "<C-w><C-l>", { desc = "Go to the right window" })
nnoremap("<C-h>", "<C-w><C-h>", { desc = "Go to the left window" })

-- nnoremap("<A-k>", "<Cmd>resize +3<CR>", { desc = "Resize window up" })
-- nnoremap("<A-j>", "<Cmd>resize -3<CR>", { desc = "Resize window down" })
-- nnoremap("<A-l>", "<Cmd>vertical resize +3<CR>", { desc = "Resize window left" })
-- nnoremap("<A-h>", "<Cmd>vertical resize -3<CR>", { desc = "Resize window right" })
-- }}}

-- Buffer {{{
noremap("<Tab>", "<CMD>bn<CR>", { desc = "Go to next buffer" })
noremap("<S-Tab>", "<CMD>bp<CR>", { desc = "Go to previous buffer" })

local function close_buffer()
  if vim.bo.buftype == "terminal" then
    vim.cmd(vim.bo.buflisted and "set nobl | new" or "hide")
  elseif vim.bo.modified then
    print("save the file first!")
  else
    local bufnr = vim.api.nvim_get_current_buf()
    vim.cmd("bp")
    vim.cmd("bd" .. bufnr)
  end
end

nnoremap("<A-q>", close_buffer, { desc = "close file" })
nnoremap("<A-S-q>", "<C-o>", { desc = "Restore closed file" })

--}}}

-- Others {{{
inoremap("<C-W>", "<C-S-W>", {
  desc = "Delete word backwards",
})

vnoremap("<", "<gv", { desc = "Dedent current selection" })
vnoremap(">", ">gv", { desc = "Indent current selection" })

nnoremap("u", "<CMD>undo<CR>", { desc = "Undo" })
nnoremap("U", "<CMD>redo<CR>", { desc = "Redo" })
nnoremap("Y", "y$", { desc = "Copy current line" })

-- Alt-Backspace to Delete Word
inoremap("<A-BS>", "<C-w>")
nnoremap("<A-BS>", "i<C-w>")
cnoremap("<A-BS>", "<C-w>")

-- }}}
