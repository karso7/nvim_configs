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

    -- Keeps tool-call JSON valid and small enough to never be truncated in
    -- flight. Sent as part of the system context so it survives agent tool
    -- modes, which drop the default system prompt.
    local tool_guardrails = [[<toolCallGuardrails>
When calling tools:
- Emit strictly valid JSON arguments: quote every string and value; never use bare identifiers.
- Keep each tool call's arguments small (roughly under 2 KB).
- For large files, split the work into multiple smaller, targeted tool calls.
- Prefer anchored search/replace edits over whole-file overwrites.
- Never put an entire large file into a single JSON string argument.
</toolCallGuardrails>]]

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

      -- Placed last so the guardrails sit closest to the current task.
      table.insert(parts, tool_guardrails)

      return table.concat(parts, "\n\n")
    end

    cc.setup({
        -- Disable DeepSeek thinking/reasoning at the API level. This sends
        -- `thinking = { type = "disabled" }` in the request body and makes
        -- the adapter drop `reasoning_effort` (see deepseek.lua).
        adapters = {
          http = {
            deepseek = function()
              return require("codecompanion.adapters").extend("deepseek", {
                schema = {
                  ["thinking.type"] = {
                    default = "disabled",
                  },
                },
              })
            end,
          },
        },

        --opts = {
        --    log_level = "TRACE", -- or "DEBUG"
        --},
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
              {
                role = "user",
                content = [[
Here is the current buffer:
#{buffer}

*** do not use 'dir' os command instead allways use 'dir /b' 

You may use any of below tools:
  @{files}
  @{read_file}
  @{delete_file}
  @{create_file}
  @{insert_edit_into_file}
  @{run_command}


                ]],
              }
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
#{diagnostics}

* do not use 'dir' command instead allways use 'dir /b' 

Fix the issues using:
  @{files}
  @{read_file}
  @{delete_file}
  @{create_file}
  @{insert_edit_into_file}
  @{run_command}

                ]],
              }
            },
          },
        },

        interactions  = {
          opts = {
            date_format = "%Y-%m-%d",
          },
          inline = { adapter = {name = "deepseek", model = "deepseek-v4-flash"} },
          cmd    = { adapter = {name = "deepseek", model = "deepseek-v4-flash"} },
          chat   = {
            adapter = {name = "deepseek", model = "deepseek-v4-flash"},
            roles = {
              llm = function(adapter)
                return "CodeCompanion (" .. adapter.formatted_name .. ")"
              end,
              user = "Me (Ctrl+S to submit prompt, # or @ for functions calls, ? for help)",
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
