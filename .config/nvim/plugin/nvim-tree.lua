vim.pack.add({
  'https://github.com/nvim-tree/nvim-tree.lua',
})

local api = require('nvim-tree.api')

require('nvim-tree').setup({
  view = {
    side = 'left',
    width = 30,
  },
  renderer = {
    group_empty = true,
  },
  on_attach = function(bufnr)
    api.map.on_attach.default(bufnr)
    vim.keymap.set('n', 'gR', api.node.expand, {
      buffer = bufnr,
      desc = 'Recursively expand directory',
    })
  end,
})

vim.keymap.set('n', '<leader>e', function()
  api.tree.toggle()
end, {
  desc = 'Toggle file tree',
})
