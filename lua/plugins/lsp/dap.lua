return {
  "mfussenegger/nvim-dap",
  ft = 'python',
  dependencies = {
    "mfussenegger/nvim-dap-python",
    "nvim-neotest/nvim-nio",
    "rcarriga/nvim-dap-ui",
  },
  config = function()
    local dap = require("dap")
    local dapui = require("dapui")
    local dap_python = require("dap-python")
    local python_path_from_mason = table.concat({ vim.fn.stdpath('data'),  'mason', 'packages', 'debugpy', 'venv', 'Scripts', 'python'}, '/'):gsub('//+', '/')
    local hover_open = nil

    dapui.setup()
    dap_python.setup(python_path_from_mason)

    dap.listeners.before.attach.dapui_config = function()
      dapui.open()
    end
    dap.listeners.before.launch.dapui_config = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated.dapui_config = function()
      dapui.close()
    end
    dap.listeners.before.event_exited.dapui_config = function()
      dapui.close()
    end
    vim.api.nvim_set_hl(0, "dapgreen",  { fg = "#9ece6a" })
    vim.fn.sign_define('DapBreakpoint',{ text ='🟥', texthl ='', linehl ='', numhl =''})
    vim.fn.sign_define('DapStopped',{ text ='', texthl ='dapgreen', linehl ='', numhl =''})

    vim.keymap.set('n', '<F5>', function() dap.continue() end, { desc = "Debug - Start" })
    vim.keymap.set('n', '<F10>', function() dap.step_over() end, { desc = "Debug - move over" })
    vim.keymap.set('n', '<F11>', function() dap.step_into() end, { desc = "Debug - move into" })
    vim.keymap.set('n', '<F12>', function() dap.step_out() end, { desc = "Debug - move out" })
    vim.keymap.set('n', '<Leader>db', function() dap.toggle_breakpoint() end, { desc = "Debug - toggle breakpoint" })
    vim.keymap.set('n', '<Leader>dlp', function() dap.set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end, { desc = "Debug - log message if line is reached" })
    vim.keymap.set('n', '<Leader>dr', function() dap.repl.open() end, { desc = "Debug - open reple" })
    vim.keymap.set('n', '<Leader>dl', function() dap.run_last() end, { desc = "Debug - run last" })
    vim.keymap.set('n', '<Leader>dj', function() dap.goto_(nil) end, { desc = "Debug - jump to line under cursor" })
    vim.keymap.set('n', '<Leader>dt', function() dap.terminate({all = true}) end, { desc = "Debug - terminate" })
    vim.keymap.set({'n', 'v'}, '<Leader>dh', function()
      if hover_open then
        hover_open.close()
        hover_open = nil
      else
        hover_open = require('dap.ui.widgets').hover()
      end
    end, { desc = "Debug - toggle hover widget" })
  end,
}
