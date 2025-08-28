return {
  "mason-org/mason.nvim",  -- was "williamboman/mason.nvim"
  dependencies = {
    "mason-org/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
  },
  config = function()
    local mason = require("mason")
    local mason_lspconfig = require("mason-lspconfig")
    local mason_tool_installer = require("mason-tool-installer")

    mason.setup({
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    })

    mason_lspconfig.setup({
      ensure_installed = {
        "lua_ls",
        "emmet_ls",
        "basedpyright",
        "efm",
      },
      automatic_installation = true,
      automatic_enable = false
    })

    mason_tool_installer.setup({
      ensure_installed = {
        "ruff", -- python linter
        "black", -- python formatter
        "debugpy",  -- python debugger (dap adapter)
      },
    })
  end,
}

