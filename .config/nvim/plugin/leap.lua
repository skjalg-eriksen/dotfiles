-- if true then return end

vim.pack.add({
  'https://codeberg.org/andyg/leap.nvim',
})

vim.keymap.set({ 'n', 'x', 'o' }, 's', function()
  require('leap').leap({
    target_windows = { vim.api.nvim_get_current_win() },
  })
end, {
  desc = 'Leap anywhere in current visible window',
})
