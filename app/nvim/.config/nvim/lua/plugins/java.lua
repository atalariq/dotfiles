vim.lsp.config("jdtls", {
  root_markers = {
    ".java-project",
    "pom.xml",
    "build.gradle",
    "settings.gradle",
    "src",
  },
})

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        jdtls = {
          root_markers = {
            ".java-project",
            "pom.xml",
            "build.gradle",
            "settings.gradle",
            "src",
          },
        },
      },
      setup = {
        jdtls = function()
          return true -- avoid duplicate servers
        end,
      },
    },
  },
}
