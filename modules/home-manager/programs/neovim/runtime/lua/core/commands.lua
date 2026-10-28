-- `git` and `crit` stay native commands; this only runs them in a terminal at
-- the repository root instead of wherever the buffer happens to be.
local Terminal = require("toggleterm.terminal").Terminal

local function repo_root()
  local out = vim.fn.systemlist({ "git", "rev-parse", "--show-toplevel" })
  if vim.v.shell_error == 0 and out[1] and out[1] ~= "" then
    return out[1]
  end
  return vim.fn.getcwd()
end

local function run(cmd)
  Terminal:new({
    cmd = cmd,
    dir = repo_root(),
    direction = "float",
    hidden = true,
  }):toggle()
end

vim.api.nvim_create_user_command("Git", function(args)
  run("git " .. table.concat(args.fargs, " "))
end, { nargs = "*", desc = "Run git at the repository root" })

vim.api.nvim_create_user_command("Crit", function()
  run("crit")
end, { desc = "Review the current changes with crit" })
