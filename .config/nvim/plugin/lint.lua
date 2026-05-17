-- if true then return end

vim.pack.add({
  'https://github.com/mfussenegger/nvim-lint',
})

local lint = require('lint')

lint.linters_by_ft = {
  python = { 'ruff' },

  dockerfile = { 'hadolint' },

  sh = { 'shellcheck' },
  bash = { 'shellcheck' },

  -- haskell = { 'hlint' },
}

local lint_augroup = vim.api.nvim_create_augroup('nm_lint', {
  clear = true,
})

vim.api.nvim_create_autocmd({
  'BufEnter',
  'BufWritePost',
  'InsertLeave',
}, {
  group = lint_augroup,
  callback = function()
    require('lint').try_lint()
  end,
})

vim.keymap.set('n', '<leader>ll', function()
  require('lint').try_lint()
end, {
  desc = 'Lint current buffer',
})
