-- Setup lspconfig.
local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())

local nvim_lsp = require('lspconfig')



-- Mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
local opts = { noremap=true, silent=true }
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'gh', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, bufopts)
  vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
  vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, bufopts)
end


-- Use a loop to conveniently call 'setup' on multiple servers and
-- map buffer local keybindings when the language server attaches
-- typescript: tssserver:  npm i -g typescript typescript-language-server
-- python: pyright: npm i -g pyright
-- c#: csharp_ls: dotnet tool install --global csharp-ls
-- c#: OmniSharp
local servers = { 'pyright', 'tsserver', 'lua_ls', 'clangd'}
for _, lsp in ipairs(servers) do
    nvim_lsp[lsp].setup {
	    on_attach = on_attach,
		capabilities = capabilities,
		flags = {
		    debounce_text_changes = 150,
		    }
	}
end

nvim_lsp.efm.setup {
	on_attach = on_attach,
	capabilities = capabilities,
    init_options = {
        documentFormatting = true
    },
    settings = {
        rootMarkers = {".venv/",".git/"},
        languages = {
            python = {
                {
                    formatCommand = "flake8 -format",
                    formatStdin = true,
                    lintCommand = "flake8 --stdin-display-name ${INPUT} -",
                    lintIgnoreExitCode = true,
                    lintStdin = true,
                    lintFormats = {"%f:%l:%c: %m"},
               }
            }
        }
    }
}

local omnisharp_bin = "C:/Work/bin/omnisharp-win-x64/OmniSharp.exe" 
local pid = vim.fn.getpid()
nvim_lsp.omnisharp.setup {
    on_attach = on_attach,
    capabilities = capabilities,
    cmd = { omnisharp_bin, "--languageserver" , "--hostPID", tostring(pid) },
    flags = {
        debounce_text_changes = 150,
        }
}