return {
  "neovim/nvim-lspconfig",
  lazy = false,
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    { "antosha417/nvim-lsp-file-operations", config = true },
  },
  config = function()
    -- import lspconfig plugin
    local lspconfig = require("lspconfig")
    local util = require("lspconfig.util")
    -- import cmp-nvim-lsp plugin
    local cmp_nvim_lsp = require("cmp_nvim_lsp")

    vim.diagnostic.config({
        float = {
              source = "always", -- <-- show the source in floating window
              border = "rounded",
        }
    })

    local keymap = vim.keymap -- for conciseness

    local opts = { noremap = true, silent = true }

    local on_attach = function(client, bufnr)
      opts.buffer = bufnr

      -- set key binds
      -- Go to
      opts.desc = "LSP - Go to declaration"
      keymap.set("n", "<leader>gD", vim.lsp.buf.declaration, opts) -- go to declaration

      opts.desc = "LSP - Go to definitions"
      keymap.set("n", "<leader>gd", "<cmd>Telescope lsp_definitions<CR>", opts) -- show lsp definitions

      opts.desc = "LSP - Go to implementations"
      keymap.set("n", "<leader>gi", "<cmd>Telescope lsp_implementations<CR>", opts) -- show lsp implementations

      opts.desc = "LSP - Go to type definitions"
      keymap.set("n", "<leader>gt", "<cmd>Telescope lsp_type_definitions<CR>", opts) -- show lsp type definitions

      -- Show
      opts.desc = "LSP - Show buffer diagnostics"
      keymap.set("n", "<leader>sD", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- show  diagnostics for file

      opts.desc = "LSP - Show line diagnostics"
      keymap.set("n", "<leader>sd", vim.diagnostic.open_float, opts) -- show diagnostics for line

      opts.desc = "LSP - Go to previous diagnostic"
      keymap.set("n", "<leader>[d", vim.diagnostic.goto_prev, opts) -- jump to previous diagnostic in buffer

      opts.desc = "LSP - Go to next diagnostic"
      keymap.set("n", "<leader>]d", vim.diagnostic.goto_next, opts) -- jump to next diagnostic in buffer

      opts.desc = "LSP - Show references"
      keymap.set("n", "<leader>sr", "<cmd>Telescope lsp_references<CR>", opts) -- show references

      opts.desc = "LSP - Show documentation for what is under cursor"
      keymap.set("n", "<leader>sh", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor

      opts.desc = "LSP - Show signature help"
      keymap.set('n', '<leader>ss', vim.lsp.buf.signature_help, opts)

      opts.desc = "LSP - Show incoming calls"
      keymap.set('n', '<leader>si', vim.lsp.buf.incoming_calls, opts)

      opts.desc = "LSP - Show outgoing calls"
      keymap.set('n', '<leader>so', vim.lsp.buf.outgoing_calls, opts)

      -- actions
      opts.desc = "LSP - See available code actions"
      keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection

      opts.desc = "LSP - Smart rename"
      keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts) -- smart rename

      opts.desc = "LSP - Format buffer"
      keymap.set('n', '<S-A-f>', function()
        vim.lsp.buf.format { async = false }
      end, opts)


      opts.desc = "LSP - Restart LSP"
      keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts) -- mapping to restart lsp if necessary
    end

    -- used to enable autocompletion (assign to every lsp server config)
    local capabilities = cmp_nvim_lsp.default_capabilities()

    -- configure html server
    lspconfig["html"].setup({
      capabilities = capabilities,
      on_attach = on_attach,
    })

    -- configure typescript server with plugin
    lspconfig["ts_ls"].setup({
      capabilities = capabilities,
      on_attach = on_attach,
    })

    -- configure css server
    lspconfig["cssls"].setup({
      capabilities = capabilities,
      on_attach = on_attach,
    })

    -- configure emmet language server
    lspconfig["emmet_ls"].setup({
      capabilities = capabilities,
      on_attach = on_attach,
      filetypes = { "html", "typescriptreact", "javascriptreact", "css", "sass", "scss", "less", "svelte" },
    })

    -- configure python server
    lspconfig["pyright"].setup({
      capabilities = capabilities,
      on_attach = on_attach,
    })

    -- configure lua server (with special settings)
    lspconfig["lua_ls"].setup({
      capabilities = capabilities,
      on_attach = on_attach,
      settings = { -- custom settings for lua
        Lua = {
          -- make the language server recognize "vim" global
          diagnostics = {
            globals = { "vim" },
          },
          workspace = {
            -- make language server aware of runtime files
            library = {
              [vim.fn.expand("$VIMRUNTIME/lua")] = true,
              [vim.fn.stdpath("config") .. "/lua"] = true,
            },
          },
        },
      },
    })

    -- configure powershell
    lspconfig["powershell_es"].setup({
      capabilities = capabilities,
      on_attach = on_attach,
      bundle_path = vim.fn.stdpath("data") .. "/mason/packages/powershell-editor-services/",
      shell = "powershell.exe",
    })

    -- configure linters
    lspconfig.efm.setup {
      on_attach = on_attach,
      capabilities = capabilities,
      init_options = {
        documentFormatting = true
      },
      root_dir = util.root_pattern("pyproject.toml", ".venv", ".git"),
      settings = {
        rootMarkers = {"pyproject.toml", ".venv", ".git"},
        languages = {
          python = {
            {
              lintCommand = "ruff check --stdin-filename ${INPUT} -",
              lintStdin = true,
              lintFormats = { "%f:%l:%c: %t%n %m" },
              lintIgnoreExitCode = true,
              formatCommand = "ruff format --stdin-filename ${INPUT} -",
              formatStdin = true,
            }
          }
        }
      }
    }
  end,
}
