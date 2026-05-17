-- if true then return end

vim.pack.add({
  'https://github.com/catppuccin/nvim',
})

require('catppuccin').setup({
  flavour = 'mocha',

  transparent_background = true,

  integrations = {
    treesitter = true,
    native_lsp = {
      enabled = true,
    },
  },
})

vim.cmd.colorscheme('catppuccin')
