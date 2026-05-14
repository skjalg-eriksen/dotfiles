-- if true then return end

vim.pack.add({
  'https://github.com/nvim-mini/mini.pick',
  'https://github.com/nvim-mini/mini.extra',
})

require('mini.pick').setup()
require('mini.extra').setup()

vim.keymap.set('n', '<leader>b', function()
  local delete_cur = function()
    local current = MiniPick.get_picker_matches().current

    if current == nil or current.bufnr == nil then
      return false
    end

    if vim.bo[current.bufnr].modified then
      vim.notify('Buffer has unsaved changes', vim.log.levels.WARN)
      return false
    end

    vim.api.nvim_buf_delete(current.bufnr, {})

    local items = MiniPick.get_picker_items()
    if items == nil then
      return false
    end

    local new_items = vim.tbl_filter(function(item)
      return item.bufnr ~= current.bufnr
    end, items)

    MiniPick.set_picker_items(new_items)

    return false
  end

  MiniPick.builtin.buffers({}, {
    mappings = {
      delete = {
        char = '<C-d>',
        func = delete_cur,
      },
    },
  })
end, {
  desc = 'Pick buffer',
})

vim.keymap.set('n', '<leader>ff', function()
  MiniPick.builtin.files()
end, {
  desc = 'Find files',
})

vim.keymap.set('n', '<leader>fw', function()
  MiniPick.builtin.grep_live()
end, {
  desc = 'Live grep',
})

vim.keymap.set('n', '<leader>fh', function()
  MiniPick.builtin.help()
end, {
  desc = 'Help tags',
})
