-- command for checking changes in unsaved buffer
vim.cmd 'command DiffOrig vert new | set buftype=nofile | read ++edit # | 0d_ | diffthis | wincmd p | diffthis'

-- Define :Capture <vim-command> to insert output into buffer
vim.api.nvim_create_user_command(
  'Capture',
  function(opts)
    -- Redirect output to register a
    vim.cmd('redir @a')
    vim.cmd('silent ' .. opts.args)
    vim.cmd('redir END')
    -- Insert the contents of register a below cursor
    vim.cmd('put a')
  end,
  { nargs = '+' } -- at least one argument required
  ) 
