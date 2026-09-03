local jumpmotion = require('jumpmotion')
jumpmotion.setup()
vim.keymap.set('n', jumpmotion.config.mapping, jumpmotion.jump, {
  desc = 'Incremental jump (<Enter> then label resolves collisions)',
})
