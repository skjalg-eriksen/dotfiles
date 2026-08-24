vim.pack.add({
  'https://github.com/stevearc/oil.nvim',
})

require('oil').setup()

vim.keymap.set('n', '<leader>E', '<cmd>Oil<cr>', {
  desc = 'Open Oil file explorer',
})
