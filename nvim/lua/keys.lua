-- Navigate between splits
vim.keymap.set("n", "<leader>h", "<C-w>h", { desc = "Go to left window" })
vim.keymap.set("n", "<leader>j", "<C-w>j", { desc = "Go to bottom window" })
vim.keymap.set("n", "<leader>k", "<C-w>k", { desc = "Go to top window" })
vim.keymap.set("n", "<leader>l", "<C-w>l", { desc = "Go to right window" })

-- Create splits quickly using the same muscle memory
vim.keymap.set("n", "<leader>v", "<C-w>v", { desc = "Split window vertically" })
vim.keymap.set("n", "<leader>s", "<C-w>s", { desc = "Split window horizontally" })

-- Hold Ctrl and use HJKL to continuously resize windows
vim.keymap.set("n", "<C-K>", ":resize +2<CR>", { silent = true, desc = "Make window taller" })
vim.keymap.set("n", "<C-J>", ":resize -2<CR>", { silent = true, desc = "Make window shorter" })
vim.keymap.set("n", "<C-H>", ":vertical resize -2<CR>", { silent = true, desc = "Make window narrower" })
vim.keymap.set("n", "<C-L>", ":vertical resize +2<CR>", { silent = true, desc = "Make window wider" })

-- Close windows
vim.keymap.set("n", "<leader>q", "<C-w>c", { desc = "Close current split" })

-- select all
vim.keymap.set('n', '<C-a>', 'ggVG', { desc = 'Select All' })

-- pasting over a selection no longer clobbers your clipboard
vim.cmd([[ xnoremap <expr> p 'pgv"'.v:register.'y' ]])
