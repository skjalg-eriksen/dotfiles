-- buffers
vim.keymap.set('n', '<leader>w', '<cmd>w<cr>', {
  desc = 'Save buffer',
})


vim.keymap.set('n', '<leader>q', '<cmd>bd<cr>', {
  desc = 'Close buffer',
})

vim.keymap.set('n', '<leader>QQ', '<cmd>qall!<cr>', {
  desc = 'Force quit Neovim',
})

-- Editing
vim.keymap.set('n', 'U', '<C-r>', {
  desc = 'Redo',
})

local resize_mode_active = false

local function show_resize_mode()
  vim.api.nvim_echo({
    { ' RESIZE MODE ', 'WarningMsg' },
    { ' h/j/k/l resize  q/Esc/Enter/Space exit ', 'ModeMsg' },
  }, false, {})
end

local function exit_resize_mode()
  if not resize_mode_active then
    return
  end

  resize_mode_active = false
  for _, key in ipairs({ 'h', 'j', 'k', 'l', 'q', '<Esc>', '<CR>', '<Space>' }) do
    vim.keymap.del('n', key)
  end
  vim.cmd('echo ""')
end

local function enter_resize_mode()
  if resize_mode_active then
    return
  end

  resize_mode_active = true
  local resize_keys = {
    h = 'vertical resize -5',
    j = 'resize +2',
    k = 'resize -2',
    l = 'vertical resize +5',
  }

  for key, command in pairs(resize_keys) do
    vim.keymap.set('n', key, function()
      vim.cmd(command)
      show_resize_mode()
    end, { nowait = true })
  end

  for _, key in ipairs({ 'q', '<Esc>', '<CR>', '<Space>' }) do
    vim.keymap.set('n', key, exit_resize_mode, { nowait = true })
  end
  show_resize_mode()
end

vim.keymap.set('n', '<leader>R', enter_resize_mode, {
  desc = 'Resize mode',
})


-- disable shift movement
vim.keymap.set({ "n", "v", "i" }, "<S-Up>", "<Up>")
vim.keymap.set({ "n", "v", "i" }, "<S-Down>", "<Down>")
vim.keymap.set({ "n", "v", "i" }, "<S-Left>", "<Left>")
vim.keymap.set({ "n", "v", "i" }, "<S-Right>", "<Right>")
