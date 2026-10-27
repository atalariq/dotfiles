-- Nix: modules/40-languages.nix (ccache via gcc wrapper; ftplugin-local options stay here)
if 1 == vim.fn.executable("ccache") then
  vim.fn.setenv("CMAKE_C_COMPILER_LAUNCHER", "ccache")
  vim.fn.setenv("CMAKE_CXX_COMPILER_LAUNCHER", "ccache")
end
