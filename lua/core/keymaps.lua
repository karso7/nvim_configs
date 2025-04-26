-- set leader key to space
vim.g.mapleader = " "

local keymap = vim.keymap -- for conciseness

---------------------
-- General Keymaps -------------------

-- clear search highlights
keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

-- Explorer
keymap.set("n", "<leader>ee", "<cmd>Exp<CR>", { desc = "Show/Hide file explorer" })

--  new tab
keymap.set("n", "<C-w>t", "<cmd>tabnew<CR>", { desc = "Open new tab" })

-- window management
keymap.set("t", "<C-w><S-N>", "<C-\\><C-n>", { desc = "Exit terminal's interactive mode" })

keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" }) -- split window vertically
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" }) -- split window horizontally
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" }) -- make split windows equal width & height
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" }) -- close current split window

keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" }) -- open new tab
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" }) -- close current tab
keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" }) --  go to next tab
keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" }) --  go to previous tab
keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" }) --  move current buffer to new tab

-- diff
keymap.set("n", "<leader>do", "<cmd>.diffget<CR>", { desc = "copy line from other buffor" })
keymap.set("n", "<leader>dp", "<cmd>.diffput<CR>", { desc = "copy line to other buffor" })
