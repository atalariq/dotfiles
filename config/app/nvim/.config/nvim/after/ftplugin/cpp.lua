-- local nproc = tonumber(vim.fn.system({ "nproc" }))
-- local jnproc = ""
--
-- if 0 ~= nproc then
--   jnproc = "--j=" .. (nproc - 1)
-- end

if 1 == vim.fn.executable("clang") and 1 == vim.fn.executable("clang++") then
  vim.fn.setenv("CC", "/usr/bin/clang")
  vim.fn.setenv("CXX", "/usr/bin/clang++")
end

if 1 == vim.fn.executable("ccache") then
  vim.fn.setenv("CMAKE_C_COMPILER_LAUNCHER", "ccache")
  vim.fn.setenv("CMAKE_CXX_COMPILER_LAUNCHER", "ccache")
end
