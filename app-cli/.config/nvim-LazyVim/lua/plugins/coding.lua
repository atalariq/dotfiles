return {
  -- LSP
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = {
        enabled = true,
      },
      -- setup = {
      --   clangd = function(_, opts)
      --     opts.capabilities.offsetEncoding = { "utf-16" }
      --   end,
      -- },
    },
  },
}
