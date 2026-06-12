local ok, dap = pcall(require, "dap")
if not ok then
  return
end

local function executable(cmd)
  return vim.fn.executable(cmd) == 1
end

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

-- Bash / JS / PHP need distro-specific adapter entrypoints. Keep Android/Kotlin
-- debugging out of Neovim; Android Studio remains the sane fallback.
