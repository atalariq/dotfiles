-- Nix: modules/40-languages.nix (parser set; Lua only attaches installed parsers)
-- Parsers are built by Nix; FileType only attaches installed parsers.
-- https://mise.jdx.dev/mise-cookbook/neovim.html
require("vim.treesitter.query").add_predicate("is-mise?", function(_, _, bufnr, _)
  local filepath = vim.api.nvim_buf_get_name(tonumber(bufnr) or 0)
  local filename = vim.fn.fnamemodify(filepath, ":t")
  return string.match(filename, ".*mise.*%.toml$") ~= nil
end, { force = true, all = false })

local function treesitter_try_attach(buf, language)
  -- Check if a parser exists and load it
  local ok, loaded = pcall(vim.treesitter.language.add, language)
  if not ok or not loaded then
    return
  end
  -- Enable syntax highlighting and other treesitter features
  vim.treesitter.start(buf, language)

  -- Enable treesitter based folds
  -- For more info on folds see `:help folds`
  -- vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
  -- vim.wo.foldmethod = 'expr'

  -- Check if treesitter indentation is available for this language, and if so enable it
  -- in case there is no indent query, the indentexpr will fallback to the vim's built in one
  local has_indent_query = vim.treesitter.query.get(language, "indents") ~= nil

  -- Enable treesitter based indentation
  if has_indent_query then
    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end
end

vim.api.nvim_create_autocmd("FileType", {
  callback = function(args)
    local buf, filetype = args.buf, args.match

    local language = vim.treesitter.language.get_lang(filetype)
    if not language then
      return
    end

    treesitter_try_attach(buf, language)
  end,
})
