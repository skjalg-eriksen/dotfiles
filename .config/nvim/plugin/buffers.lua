vim.pack.add({ 'https://github.com/dmtrKovalenko/fff.nvim' })

vim.pack.add({
 'https://github.com/nvim-mini/mini.pick',
  'https://github.com/nvim-mini/mini.extra',
'https://github.com/dmtrKovalenko/fff.nvim' })


vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if name == 'fff.nvim' and (kind == 'install' or kind == 'update') then
      if not ev.data.active then vim.cmd.packadd('fff.nvim') end
      require('fff.download').download_or_build_binary()
    end
  end,
})

require('fff').setup()

vim.keymap.set('n', '<leader>b', function()
  local infos = vim.fn.getbufinfo({ buflisted = 1 })

  table.sort(infos, function(a, b)
    return a.lastused > b.lastused
  end)

  local items = vim.tbl_map(function(info)
    local name = info.name ~= '' and vim.fn.fnamemodify(info.name, ':.') or '[No Name]'
    local modified = info.changed == 1 and ' [+]' or ''
    return string.format('%3d  %s%s', info.bufnr, name, modified)
  end, infos)

  require('mini.pick').start({
    source = {
      items = items,
      name = 'Buffers',
      choose = function(choice)
        local bufnr = tonumber(choice:match('^%s*(%d+)'))
        if bufnr then vim.cmd.buffer(bufnr) end
      end,
    },
  })
end, {
  desc = 'Pick buffer',
})

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
  require('fff').live_grep({ grep = { modes = { 'fuzzy', 'plain' } } })
end, {
  desc = 'Fuzzy grep',
})
