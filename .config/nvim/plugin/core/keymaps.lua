-- buffers
vim.keymap.set('n', '<leader>w', '<cmd>w<cr>', {
  desc = 'Save buffer',
})
vim.keymap.set('n', '<leader>c', '<cmd>bd<cr>', {
  desc = 'Close buffer',
})

-- files
vim.keymap.set('n', '<leader>e', '<cmd>Explor<cr>', {
  desc = 'open file explorer',
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
