local dap = require("dap")
local dapui = require("dapui")

-- Setup DAP UI
dapui.setup({
  controls = {
    element = "repl",
    enabled = true,
    icons = {
      disconnect = "⏹",
      pause = "⏸",
      play = "▶",
      run_last = "↻",
      step_back = "↶",
      step_into = "⇣",
      step_out = "⇡",
      step_over = "⇢",
      terminate = "⏹"
    }
  },
  element_mappings = {},
  expand_lines = true,
  floating = {
    border = "single",
    mappings = {
      close = { "q", "<Esc>" }
    }
  },
  force_buffers = true,
  icons = {
    collapsed = "▶",     -- Right-pointing triangle for collapsed items
    current_frame = "▶", -- Highlights current execution frame
    expanded = "▼"       -- Down-pointing triangle for expanded items
  },
  layouts = { {
      elements = { {
          id = "scopes",
          size = 0.25
        }, {
          id = "breakpoints",
          size = 0.25
        }, {
          id = "stacks",
          size = 0.25
        }, {
          id = "watches",
          size = 0.25
        } },
      position = "left",
      size = 40
    }, {
      elements = { {
          id = "repl",
          size = 0.5
        }, {
          id = "console",
          size = 0.5
        } },
      position = "bottom",
      size = 10
    } },
  mappings = {
    edit = "e",
    expand = { "<CR>", "<2-LeftMouse>" },
    open = "o",
    remove = "d",
    repl = "r",
    toggle = "t"
  },
  render = {
    indent = 1,
    max_value_lines = 100
  }
})

-- Auto-open/close DAP UI
dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close()
end

-- Java DAP configurations
dap.configurations.java = dap.configurations.java or {}

-- Attach to a JVM that has JDWP open (e.g., Spring Boot on 5005)
table.insert(dap.configurations.java, {
  type = "java",
  request = "attach",
  name = "Attach: Spring Boot (localhost:5005)",
  hostName = "127.0.0.1",
  port = 5005,
})

-- Remote debugging on different port
table.insert(dap.configurations.java, {
  type = "java",
  request = "attach",
  name = "Attach: Remote Debug (localhost:8000)",
  hostName = "127.0.0.1",
  port = 8000,
})

