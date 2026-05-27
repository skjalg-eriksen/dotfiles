-- if true then return end

vim.g.tmux_navigator_no_mappings = 1

vim.pack.add({
  'https://github.com/christoomey/vim-tmux-navigator',
})

local navigation_keys = {
  { '<C-h>', [[<cmd>TmuxNavigateLeft<cr>]], 'Navigate left' },
  { '<C-j>', [[<cmd>TmuxNavigateDown<cr>]], 'Navigate down' },
  { '<C-k>', [[<cmd>TmuxNavigateUp<cr>]], 'Navigate up' },
  { '<C-l>', [[<cmd>TmuxNavigateRight<cr>]], 'Navigate right' },
  { [=[<C-\>]=], [[<cmd>TmuxNavigatePrevious<cr>]], 'Navigate previous pane' },
}

for _, key in ipairs(navigation_keys) do
  vim.keymap.set('n', key[1], key[2], {
    desc = key[3],
    silent = true,
  })
end
