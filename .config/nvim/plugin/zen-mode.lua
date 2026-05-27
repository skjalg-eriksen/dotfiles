vim.pack.add({
  'https://github.com/folke/zen-mode.nvim',
})

require('zen-mode').setup({})

local function toggle_zen_mode()
  require('zen-mode').toggle()
end

local ok, which_key = pcall(require, 'which-key')
if ok and which_key.add then
  which_key.add({
    { '<leader>u', group = 'UI Toggles' },
    { '<leader>uz', toggle_zen_mode, desc = 'Toggle zen mode' },
  })
else
  vim.keymap.set('n', '<leader>uz', toggle_zen_mode, {
    desc = 'Toggle zen mode',
  })
end
