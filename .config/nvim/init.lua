-- packages
vim.pack.add({
  'https://github.com/neovim/nvim-lspconfig',
  'https://github.com/nvim-treesitter/nvim-treesitter',
})

-- lsp
vim.lsp.enable({ 
  'lua_ls', 
	'pyright' 
})

-- global leader key
vim.g.mapleader = ' '
