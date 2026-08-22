vim.pack.add({
  'https://github.com/nvim-tree/nvim-tree.lua',
})

require('nvim-tree').setup({
  view = {
    side = 'left',
    width = 30,
  },
  renderer = {
    group_empty = true,
  },
})

vim.keymap.set('n', '<leader>e', function()
  require('nvim-tree.api').tree.toggle({
    path = vim.fn.getcwd(),
  })
end, {
  desc = 'Toggle file tree',
})
