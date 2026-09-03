local jumpmotion = require('jumpmotion')

-- Configure labels, mapping, or the intentionally background-free highlights
-- here, or call require('jumpmotion').setup({ ... }) from init.lua first.
jumpmotion.setup()
vim.keymap.set('n', jumpmotion.config.mapping, jumpmotion.jump, {
  desc = 'Incremental jump (<Enter> then label resolves collisions)',
})
