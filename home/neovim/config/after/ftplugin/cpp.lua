if 1 == vim.fn.executable("ccache") then
  vim.fn.setenv("CMAKE_C_COMPILER_LAUNCHER", "ccache")
  vim.fn.setenv("CMAKE_CXX_COMPILER_LAUNCHER", "ccache")
end
