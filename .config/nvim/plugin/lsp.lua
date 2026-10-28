-- if true then return end

vim.pack.add({
  'https://github.com/neovim/nvim-lspconfig',
})

vim.lsp.config('yamlls', dofile(vim.fs.joinpath(vim.fn.stdpath('config'), 'lsp', 'yamlls.lua')))

local lsp_servers = {
  'lua_ls',
  'pyright',
  'hls',
  'csharp_ls',
  'ts_ls',
  'dockerls',
  'bashls',
  'clangd',
  'rust_analyzer',
  'zls',
  'marksman',
  'yamlls',
}

vim.lsp.enable(lsp_servers)

vim.keymap.set('n', '<leader>lt', function()
  local enabled = vim.g.nm_language_analysis_enabled ~= false
  vim.g.nm_language_analysis_enabled = not enabled
  vim.diagnostic.enable(not enabled)
  vim.lsp.enable(lsp_servers, not enabled)

  vim.notify(
    ('Language analysis %s'):format(enabled and 'disabled' or 'enabled'),
    vim.log.levels.INFO
  )
end, {
  desc = 'Toggle language analysis',
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
    map('n', '<leader>lr', vim.lsp.buf.rename, 'Rename')
    map('n', '<leader>la', vim.lsp.buf.code_action, 'Code action')
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

vim.keymap.set('i', '<Tab>', function()
  return vim.fn.pumvisible() == 1 and '<C-n>' or '<Tab>'
end, { expr = true })

vim.keymap.set('i', '<S-Tab>', function()
  return vim.fn.pumvisible() == 1 and '<C-p>' or '<S-Tab>'
end, { expr = true })

vim.keymap.set('i', '<CR>', function()
  return vim.fn.pumvisible() == 1 and '<C-y>' or '<CR>'
end, { expr = true })

vim.keymap.set('i', '<C-l>', function()
  vim.lsp.completion.get()
end, {
  desc = 'Trigger completion',
})

vim.keymap.set("n", "<leader>cc", function()
  local cmd = vim.fn.input("Compile: ", vim.bo.makeprg)
  if cmd == "" then return end

  vim.bo.makeprg = cmd
  vim.cmd("silent make!")
  vim.cmd("copen")
end, { desc = "Compile" })
