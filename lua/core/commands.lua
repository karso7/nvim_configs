-- command for checking changes in unsaved buffer
vim.cmd 'command DiffOrig vert new | set buftype=nofile | read ++edit # | 0d_ | diffthis | wincmd p | diffthis'