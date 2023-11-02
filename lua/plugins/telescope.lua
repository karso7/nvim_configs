return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")

    telescope.setup({
      defaults = {
        path_display = { "truncate " },
        file_ignore_patterns = { "node_modules", ".venv", ".git" },
        mappings = {
          i = {
            ["<C-k>"] = actions.move_selection_previous, -- move to prev result
            ["<C-j>"] = actions.move_selection_next, -- move to next result
            ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
          },
        },
      },
    })

    telescope.load_extension("fzf")
    local builtin = require('telescope.builtin')
    -- set keymaps
    local keymap = vim.keymap -- for conciseness

    keymap.set('n', '<leader>ff', builtin.find_files, { desc = "Fuzzy find files" })
    -- for this to work you need to have ripgrep installed 
    -- on wnd execute "choco install ripgrep"
    keymap.set('n', '<leader>fg', builtin.live_grep, { desc = "Fuzzy find string in files" })
    keymap.set('n', '<leader>fb', builtin.buffers, {})
    keymap.set('n', '<leader>fh', builtin.help_tags, {})
  end,
}
