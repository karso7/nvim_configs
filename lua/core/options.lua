local opt = vim.opt -- for conciseness

opt.bomb = flase	-- do not use Byte Order Mark(BOM) in files
-- line numbers
opt.relativenumber = true -- show relative line numbers
opt.number = true -- shows absolute line number on cursor line (when relative number is on)

-- tabs & indentation
opt.tabstop = 2 -- 2 spaces for tabs (prettier default)
opt.shiftwidth = 2 -- 2 spaces for indent width
opt.expandtab = true -- expand tab to spaces
opt.autoindent = true -- copy indent from current line when starting new one

-- line wrapping
opt.wrap = false -- disable line wrapping

-- search settings
opt.ignorecase = true -- ignore case when searching
opt.smartcase = true -- if you include mixed case in your search, assumes you want case-sensitive

-- cursor line
opt.cursorline = true -- highlight the current cursor line

-- appearance
vim.opt.termguicolors = true
opt.signcolumn = "yes" -- show sign column so that text doesn't shift
vim.cmd'colorscheme retrobox'

-- backspace
opt.backspace = "indent,eol,start" -- allow backspace on indent, end of line or insert mode start position

-- split windows
opt.splitright = true -- split vertical window to the right
opt.splitbelow = true -- split horizontal window to the bottom

-- turn off swapfile
opt.swapfile = true

-- language 
opt.spelllang = 'en'
opt.spell = true

-- powershell
opt.shell = 'powershell'
opt.shellcmdflag = '-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new();$PSDefaultParameterValues["\'Out-File:Encoding\'"]="\'utf8\'";'
opt.shellredir = '2>&1 | %%{ "$_" } | Out-File %s; exit $LastExitCode'
opt.shellpipe  = '2>&1 | %%{ "$_" } | tee %s; exit $LastExitCode'
opt.shellquote=''
opt.shellxquote=''

--fold
function _G.custom_fold_text()
  local line = vim.fn.getline(vim.v.foldstart)
  local line_count = vim.v.foldend - vim.v.foldstart + 1
  return "  " .. line .. ": " .. line_count .. " lines"
end
vim.opt.foldtext = 'v:lua.custom_fold_text()'
