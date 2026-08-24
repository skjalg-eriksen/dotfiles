-- buffers
vim.keymap.set('n', '<leader>w', '<cmd>w<cr>', {
  desc = 'Save buffer',
})


vim.keymap.set('n', '<leader>q', '<cmd>bd<cr>', {
  desc = 'Close buffer',
})

vim.keymap.set('n', '<leader>QQ', '<cmd>qall!<cr>', {
  desc = 'Force quit Neovim',
})

-- Editing
vim.keymap.set('n', 'U', '<C-r>', {
  desc = 'Redo',
})


-- disable shift movement
vim.keymap.set({ "n", "v", "i" }, "<S-Up>", "<Up>")
vim.keymap.set({ "n", "v", "i" }, "<S-Down>", "<Down>")
vim.keymap.set({ "n", "v", "i" }, "<S-Left>", "<Left>")
vim.keymap.set({ "n", "v", "i" }, "<S-Right>", "<Right>")
