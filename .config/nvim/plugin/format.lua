-- if true then return end

vim.pack.add({
  'https://github.com/stevearc/conform.nvim',
})

local conform = require('conform')

conform.setup({
  formatters_by_ft = {
    lua = { 'stylua' },
    python = {
      'ruff_format',
      'ruff_organize_imports',
    },
    sh = { 'shfmt' },
    bash = { 'shfmt' },
    haskell = { 'fourmolu' },
    cs = { 'csharpier' }
  },

  format_on_save = function(bufnr)
    local disabled_filetypes = {
      csharp = true,
      cs = true,
      typescript = true,
      javascript = true,
      typescriptreact = true,
      javascriptreact = true,
    }

    if disabled_filetypes[vim.bo[bufnr].filetype] then
      return
    end

    return {
      timeout_ms = 1000,
      lsp_format = 'fallback',
    }
  end,
})

vim.keymap.set('n', '<leader>f', function()
  conform.format({
    async = true,
    lsp_format = 'fallback',
  })
end, {
  desc = 'Format buffer',
})
