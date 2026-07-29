vim.pack.add({
  'https://github.com/nvim-mini/mini.pick',
})

local pick = require('mini.pick')

pick.setup()

vim.keymap.set('n', '<leader>b', function()
  pick.builtin.buffers()
end, {
  desc = 'Pick buffer',
})

-- vim.keymap.set('n', '<leader>bd', function()
--   vim.cmd.bdelete()
-- end, {
--   desc = 'Delete buffer',
-- })
