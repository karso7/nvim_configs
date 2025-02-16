return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    { "antosha417/nvim-lsp-file-operations", config = true },
  },
  config = function()
    -- import lspconfig plugin
    local lspconfig = require("lspconfig")

    -- import cmp-nvim-lsp plugin
    local cmp_nvim_lsp = require("cmp_nvim_lsp")

    local keymap = vim.keymap -- for conciseness

    local opts = { noremap = true, silent = true }

    local on_attach = function(cient, bufnr)
      opts.buffer = bufnr

      -- set keybinds
      -- Go to
      opts.desc = "Go to declaration"
      keymap.set("n", "<leader>gD", vim.lsp.buf.declaration, opts) -- go to declaration

      opts.desc = "Go to definitions"
      keymap.set("n", "<leader>gd", "<cmd>Telescope lsp_definitions<CR>", opts) -- show lsp definitions

      opts.desc = "Go to implementations"
      keymap.set("n", "<leader>gi", "<cmd>Telescope lsp_implementations<CR>", opts) -- show lsp implementations

      opts.desc = "Go to type definitions"
      keymap.set("n", "<leader>gt", "<cmd>Telescope lsp_type_definitions<CR>", opts) -- show lsp type definitions

      -- Show
      opts.desc = "Show buffer diagnostics"
      keymap.set("n", "<leader>sd", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- show  diagnostics for file

      opts.desc = "Show line diagnostics"
      keymap.set("n", "<leader>sD", vim.diagnostic.open_float, opts) -- show diagnostics for line

      opts.desc = "Go to previous diagnostic"
      keymap.set("n", "<leader>[d", vim.diagnostic.goto_prev, opts) -- jump to previous diagnostic in buffer

      opts.desc = "Go to next diagnostic"
      keymap.set("n", "<leader>]d", vim.diagnostic.goto_next, opts) -- jump to next diagnostic in buffer

      opts.desc = "Show references"
      keymap.set("n", "<leader>sr", "<cmd>Telescope lsp_references<CR>", opts) -- show references

      opts.desc = "Show documentation for what is under cursor"
      keymap.set("n", "<leader>sh", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor

      opts.desc = "Show signature help"
      keymap.set('n', '<leader>ss', vim.lsp.buf.signature_help, opts)

      opts.desc = "Show incoming calls"
      keymap.set('n', '<leader>si', vim.lsp.buf.incoming_calls, opts)

      opts.desc = "Show outgoing calls"
      keymap.set('n', '<leader>so', vim.lsp.buf.outgoing_calls, opts)

      -- actions
      opts.desc = "See available code actions"
      keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection

      opts.desc = "Smart rename"
      keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts) -- smart rename

      opts.desc = "Format buffer"
      keymap.set('n', '<S-A-f>', function()
        vim.lsp.buf.format { async = false }
      end, opts)


      opts.desc = "Restart LSP"
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
      settings = {
        rootMarkers = { ".venv/", ".git/" },
        languages = {
          python = {
            {
              formatCommand = "flake8 -format",
              formatStdin = true,
              lintCommand = "flake8 --stdin-display-name ${INPUT} -",
              lintIgnoreExitCode = true,
              lintStdin = true,
              lintFormats = { "%f:%l:%c: %m" },
            }
          }
        }
      }
    }
  end,
}
