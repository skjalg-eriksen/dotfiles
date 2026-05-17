if true then return end

vim.pack.add({
  'https://github.com/rebelot/kanagawa.nvim',
})

require('kanagawa').setup({
  transparent = true,
})

vim.cmd.colorscheme('kanagawa')
