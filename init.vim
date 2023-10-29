set enc=utf-8
tnoremap <C-w><S-n> <C-\><C-n>

" Plugins will be downloaded under the specified directory.
call plug#begin('~/AppData/Local/nvim/plugged')

" Declare the list of plugins.
Plug 'neovim/nvim-lspconfig'
Plug 'gruvbox-community/gruvbox'

" Completion engine
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'

" For vsnip users.
Plug 'hrsh7th/cmp-vsnip'
Plug 'hrsh7th/vim-vsnip'

" For react, jsx and js
" Plug 'pangloss/vim-javascript'
Plug 'alvan/vim-closetag'
Plug 'yuezk/vim-js'
Plug 'maxmellon/vim-jsx-pretty'

" lualine - status line 
Plug 'nvim-lualine/lualine.nvim'
Plug 'kyazdani42/nvim-web-devicons'

" lsp servers manager
Plug 'williamboman/mason.nvim'
Plug 'williamboman/mason-lspconfig.nvim'


" List ends here. Plugins become visible to Vim after this call.
call plug#end()
set completeopt=menu,menuone,noselect,preview

" lua e.g. LSP
lua << EOF
-- ~/AppData/Local/nvim/lua/user.lua
require("user")
-- ~/AppData/Local/nvim/lua/plugins/cmp.lua
require("plugins.cmp")
-- ~/AppData/Local/nvim/lua/plugins/lspconfig.lua
require("mason").setup()
require("mason-lspconfig").setup()
require("plugins.lspconfig")

-- ~/AppData/Local/nvim/lua/plugins/lualine.lua
require("plugins.lualine")
EOF

command DiffOrig vert new | set buftype=nofile | read ++edit # | 0d_
		\ | diffthis | wincmd p | diffthis


color retrobox
set number
set cursorline
set listchars=trail:.,tab:>-,nbsp:+,eol:$,lead:.
set spelllang=en
set signcolumn=yes
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
set smarttab
set autoindent
set t_Co=256
" set sh=powershell.exe
" let g:closetag_xhtml_filenames = '*.xhtml,*.jsx,*.tsx,*.js'
let g:closetag_filenames = '*.html,*.xhtml,*.phtml,*.jsx,*.tsx,*.js'
