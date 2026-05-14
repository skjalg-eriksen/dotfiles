
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
