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

    local python_path_from_mason = table.concat({
      vim.fn.stdpath('data'),
      'mason',
      'packages',
      'debugpy',
      'venv',
      'Scripts',
      'python'
    }, '/'):gsub('//+', '/')

    local hover_open = nil

    dapui.setup()
    dap_python.setup(python_path_from_mason)

    -- Configure pytest as test runner (instead of default unittest)
    dap_python.test_runner = 'pytest'

    -- Helper: find nearest test function name by scanning upward from cursor line
    local function get_nearest_test_node_id()
      local fname = vim.fn.expand("%:p")
      local start_row = vim.fn.line(".")

      local test_name = nil
      local class_name = nil

      for row = start_row, 1, -1 do
        local line = vim.fn.getline(row)


        if not test_name then
          local test_match = line:match("^%s*def%s+(test_[%w_]+)")
          if test_match then
            test_name = test_match
          end
        else
          local class_match = line:match("^%s*class%s+([%w_]+)")
          if class_match then
            class_name = class_match
            break
          end
        end
      end

      if not test_name then
        return nil
      end

      if class_name then
        return string.format("%s::%s::%s", fname, class_name, test_name)
      else
        return string.format("%s::%s", fname, test_name)
      end
    end

    -- adding pytest for nearest test config:
    table.insert(dap.configurations.python, {
      type = 'python',
      request = 'launch',
      name = 'pytest: nearest test',
      module = 'pytest',
      args = function()
        local node_id = get_nearest_test_node_id()
        if not node_id then
          vim.notify('No test function (def test_...) found above cursor', vim.log.levels.WARN)
            return {}
          end
          return { node_id }
        end,
        console = 'integratedTerminal',
        justMyCode = false,
      })

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
      vim.keymap.set('n', '<Leader>dr', function() dap.repl.open() end, { desc = "Debug - open repl" })
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
