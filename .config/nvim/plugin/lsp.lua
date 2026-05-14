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

-- completions
vim.opt.completeopt = {
  'menuone',
  'noselect',
  'popup',
}

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('nm_lsp_completion', { clear = true }),
  callback = function(args)
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
    local bufnr = args.buf

    if client:supports_method('textDocument/completion') then
      vim.lsp.completion.enable(true, client.id, bufnr, {
        autotrigger = true,
      })
    end
  end,
})
