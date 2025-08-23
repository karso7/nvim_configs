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

    cc.setup({
      strategies = {
        inline = { adapter = {name = "deepseek", model = "deepseek-chat"} },
        cmd    = { adapter = {name = "deepseek", model = "deepseek-chat"} },
        chat   = { 
			adapter = {name = "deepseek", model = "deepseek-chat"},
		    roles = {
				---The header name for the LLM's messages
				---@type string|fun(adapter: CodeCompanion.Adapter): string
				llm = function(adapter)
				  return "CodeCompanion (" .. adapter.formatted_name .. ")"
				end,

				---The header name for your messages
				---@type string
				user = "Me (Ctrl+S to submit prompt, ? for help)",
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
    keymap.set("v", "<leader>ae", "<cmd>CodeCompanionExplain<CR>", { desc = "AI - Explain selected code" })
    keymap.set("v", "<leader>af", "<cmd>CodeCompanionFix<CR>", { desc = "AI - Fix selected code" })
    keymap.set("v", "<leader>ag", "<cmd>CodeCompanionGenerate<CR>", { desc = "AI - Generate code" })
    keymap.set("v", "<leader>aa", "<cmd>CodeCompanionActions<CR>", { desc = "AI - Actions" })
    keymap.set("n", "<leader>aa", "<cmd>CodeCompanionActions<CR>", { desc = "AI - Actions" })
  end,
}
