-- if true then return end

vim.pack.add({
  'https://github.com/neovim/nvim-lspconfig',
})

vim.lsp.enable({ 'lua_ls',
  'pyright',
  'hls',
  'csharp_ls',
  'ts_ls',
  'dockerls',
  'bashls',
})


vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('nm_lsp_attach', { clear = true }),
  callback = function(args)
    local bufnr = args.buf

    local map = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, {
        buffer = bufnr,
        desc = desc,
      })
    end

    map('n', 'gd', vim.lsp.buf.definition, 'Go to definition')
    map('n', 'gD', vim.lsp.buf.declaration, 'Go to declaration')
    map('n', 'gr', vim.lsp.buf.references, 'References')
    map('n', 'gi', vim.lsp.buf.implementation, 'Implementation')
    map('n', 'K', vim.lsp.buf.hover, 'Hover')
    map('n', '<leader>rn', vim.lsp.buf.rename, 'Rename')
    map('n', '<leader>a', vim.lsp.buf.code_action, 'Code action')
  end,
})
