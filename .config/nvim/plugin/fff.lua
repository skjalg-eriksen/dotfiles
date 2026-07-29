local fff_group = vim.api.nvim_create_augroup('fff-build', { clear = true })

vim.api.nvim_create_autocmd('PackChanged', {
  group = fff_group,
  callback = function(ev)
    local name = ev.data.spec.name
    local kind = ev.data.kind

    if name == 'fff.nvim' and (kind == 'install' or kind == 'update') then
      if not ev.data.active then
        vim.cmd.packadd('fff.nvim')
      end

      require('fff.download').download_or_build_binary()
    end
  end,
})

vim.pack.add({
  'https://github.com/dmtrKovalenko/fff.nvim',
})

require('fff').setup()

vim.keymap.set('n', '<leader>ff', function()
  require('fff').find_files()
end, {
  desc = 'Find files',
})

vim.keymap.set('n', '<leader>fw', function()
  require('fff').live_grep()
end, {
  desc = 'Live grep',
})

vim.keymap.set('n', '<leader>fz', function()
  require('fff').live_grep({
    grep = {
      modes = { 'fuzzy', 'plain' },
    },
  })
end, {
  desc = 'Fuzzy grep',
})
