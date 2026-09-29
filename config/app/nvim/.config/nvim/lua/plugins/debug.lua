local executable = require("core.utils").executable

local dap = require("dap")
require("dap-view").setup()

if executable("dlv") then
  dap.adapters.go = function(callback, config)
    local port = config.port or 38697
    callback({
      type = "server",
      host = "127.0.0.1",
      port = port,
      executable = {
        command = "dlv",
        args = { "dap", "-l", "127.0.0.1:" .. port },
      },
    })
  end

  dap.configurations.go = {
    {
      type = "go",
      name = "Debug package",
      request = "launch",
      program = "${fileDirname}",
    },
  }
end

if executable("debugpy-adapter") then
  dap.adapters.python = {
    type = "executable",
    command = "debugpy-adapter",
  }

  dap.configurations.python = {
    {
      type = "python",
      request = "launch",
      name = "Debug current file",
      program = "${file}",
      pythonPath = function()
        if executable("python") then
          return vim.fn.exepath("python")
        end
        return "python3"
      end,
    },
  }
end

if executable("lldb-dap") then
  dap.adapters.lldb = {
    type = "executable",
    command = "lldb-dap",
    name = "lldb",
  }

  for _, ft in ipairs({ "c", "cpp", "rust" }) do
    dap.configurations[ft] = {
      {
        name = "Launch executable",
        type = "lldb",
        request = "launch",
        program = function()
          return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
        end,
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
      },
    }
  end
end
