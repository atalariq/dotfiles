-- Native markdown comfort settings. Rendering is a deliberate action.
vim.opt_local.spell = true
vim.opt_local.spelllang = { "id", "en" }
vim.opt_local.wrap = false
vim.opt_local.linebreak = true
vim.opt_local.conceallevel = 0

local function map(lhs, rhs, desc)
  vim.keymap.set("n", lhs, rhs, { buffer = true, silent = true, desc = desc })
end

local function render_markdown()
  return require("render-markdown")
end

local function toggle_render()
  if vim.bo.buftype ~= "" then
    return
  end
  local ok, rm = pcall(render_markdown)
  if ok then
    rm.buf_toggle()
    vim.opt_local.wrap = not vim.opt_local.wrap
  end
end

local function preview_open()
  local buf = vim.api.nvim_get_current_buf()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local candidate = vim.api.nvim_win_get_buf(win)
    if candidate ~= buf and vim.bo[candidate].buftype == "nofile" and vim.bo[candidate].filetype == "markdown" then
      return true
    end
  end
  return false
end

local function toggle_preview()
  if vim.bo.buftype ~= "" then
    return
  end
  local ok, rm = pcall(render_markdown)
  if not ok then
    return
  end
  local had_preview = preview_open()
  rm.preview()
  vim.opt_local.wrap = true
  if had_preview then
    rm.buf_disable()
    vim.opt_local.wrap = false
  end
end

map("<leader>mr", toggle_render, "Markdown: toggle render")
map("<leader>mR", toggle_preview, "Markdown: split preview")
map("<leader>tm", toggle_render, "Markdown: toggle render")
map("<leader>tp", "<cmd>MdKite<cr>", "Markdown: live preview")

-- Closing a preview split must not leave the source rendered.
local group = vim.api.nvim_create_augroup("dotfiles_markdown", { clear = true })
vim.api.nvim_create_autocmd("BufWipeout", {
  group = group,
  callback = function(args)
    if vim.bo[args.buf].buftype == "nofile" and vim.bo[args.buf].filetype == "markdown" then
      vim.schedule(function()
        if vim.bo.buftype == "" and vim.bo.filetype == "markdown" then
          local ok, rm = pcall(render_markdown)
          if ok then
            rm.buf_disable()
          end
        end
      end)
    end
  end,
})
