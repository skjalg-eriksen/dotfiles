vim.pack.add({
  'https://github.com/nvim-neotest/nvim-nio',
  'https://github.com/j-hui/fidget.nvim',
  'https://github.com/lunarmodules/lua-mimetypes',
  'https://github.com/manoelcampos/xml2lua',
})

for _, module in ipairs({ 'mimetypes.lua', 'xml2lua.lua' }) do
  local path = vim.api.nvim_get_runtime_file(module, false)[1]
  if path then
    package.path = vim.fs.dirname(path) .. '/?.lua;' .. package.path
  end
end

vim.g.rest_nvim = {
  ui = {
    keybinds = {
      prev = '[r',
      next = ']r',
    },
  },
}

vim.pack.add({
  'https://github.com/rest-nvim/rest.nvim',
})

require('rest_auth').setup()

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('nm_rest', { clear = true }),
  pattern = 'http',
  callback = function(args)
    local function map(lhs, rhs, desc)
      vim.keymap.set('n', lhs, rhs, {
        buffer = args.buf,
        desc = desc,
      })
    end

    map('<leader>rr', '<cmd>Rest run<cr>', 'Run HTTP request')
    map('<leader>rl', '<cmd>Rest last<cr>', 'Run last HTTP request')
    map('<leader>ro', '<cmd>Rest open<cr>', 'Open HTTP response')
  end,
})
