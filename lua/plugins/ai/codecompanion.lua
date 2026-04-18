return {
  "olimorris/codecompanion.nvim",
  lazy = false,
  dependencies = {
    "nvim-lua/plenary.nvim",       -- required
    "nvim-treesitter/nvim-treesitter", -- optional but recommended
  },

  config = function()
    local cc = require("codecompanion")
    local keymap = vim.keymap

    local get_ai_context = function()
      local cwd = vim.fn.getcwd()
      local parts = {}

      -- ai_context.txt
      local ctx_path = vim.fs.joinpath(cwd, "ai_context.txt")
      local ok1, lines1 = pcall(vim.fn.readfile, ctx_path)
      if ok1 and #lines1 > 0 then
        table.insert(parts, "-- ai_context.txt --\n" .. table.concat(lines1, "\n"))
      end

      -- pyproject.toml
      local py_path = vim.fs.joinpath(cwd, "pyproject.toml")
      local ok2, lines2 = pcall(vim.fn.readfile, py_path)
      if ok2 and #lines2 > 0 then
        table.insert(parts, "-- pyproject.toml --\n" .. table.concat(lines2, "\n"))
      end

      return table.concat(parts, "\n\n")
    end

    cc.setup({
--      opts = {
--        log_level = "TRACE", -- or "DEBUG"
--      },
      prompt_library = {
        ["Chat With Project Context"] = {
          description = "Chat with project ai_context.txt + pyproject.toml",
          strategy = "chat",
          opts = {
            is_default = true,  -- Makes it auto-used
            ignore_system_prompt = false,  -- Keeps default system prompt
          },
          prompts = {
            {
              role = "system",
              content = get_ai_context,
            },
          },
        },

        ["FixLspErrors"] = {
          strategy = "chat",
          description = "Fix errors reported by the LSP. ai_context.txt + pyproject.toml included",
          prompts = {
            {
              role = "system",
              content = get_ai_context,
            },
            {
              role = "user",
              content = [[
              Here is the current buffer:
              #{buffer}

              And here are the diagnostics and symbols from the LSP:
              #{lsp}

              Fix the issues.
              ]],
            }
          },
        },
      },

      interactions  = {
        inline = { adapter = {name = "deepseek", model = "deepseek-chat"} },
        cmd    = { adapter = {name = "deepseek", model = "deepseek-chat"} },
        chat   = { 
          adapter = {name = "deepseek", model = "deepseek-chat"},
          opts = {
            system_prompt = function(ctx)
              local custom_date = os.date("%Y-%m-%d")
              return [[You are an AI programming assistant named "CodeCompanion", working within the Neovim text editor.
              Follow the user's requirements carefully and to the letter.
              Use the context and attachments the user provides.
              Keep your answers short and impersonal.
              Use Markdown formatting in your answers. DO NOT use H1 or H2 headers.

              Additional context:
              All non-code text responses must be written in the English language.
              The current date is ]] .. custom_date .. [[.
              The user's Neovim version is ]] .. ctx.nvim_version .. [[.
              The user is working on a ]] .. ctx.os .. [[ machine. Please respond with system specific commands if applicable.
              ]]
            end,
          },
          roles = {
            ---The header name for the LLM's messages
            ---@type string|fun(adapter: CodeCompanion.Adapter): string
            llm = function(adapter)
              return "CodeCompanion (" .. adapter.formatted_name .. ")"
            end,

            ---The header name for your messages
            ---@type string
            user = "Me (Ctrl+S to submit prompt, # or @ for function callse, ? for help)",
          }
        },
      },
      ui = {
        border = "rounded",
        width = 0.45,
        height = 0.6,
      },
    })

    -- Example keymaps
    keymap.set("n", "<leader>ac", "<cmd>CodeCompanionChat<CR>", { desc = "AI - Chat with DeepSeek" })
    keymap.set("v", "<leader>aa", "<cmd>CodeCompanionActions<CR>", { desc = "AI - Actions" })
    keymap.set("n", "<leader>aa", "<cmd>CodeCompanionActions<CR>", { desc = "AI - Actions" })
  end,
}
