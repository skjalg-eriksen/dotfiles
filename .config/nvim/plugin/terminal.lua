local terminal = {
  buf = nil,
  height = 12,
}

local function is_terminal_buffer(bufnr)
  return bufnr ~= nil
    and vim.api.nvim_buf_is_valid(bufnr)
    and vim.bo[bufnr].buftype == 'terminal'
end

local function find_terminal_window()
  if not is_terminal_buffer(terminal.buf) then
    return nil
  end

  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(win) == terminal.buf then
      return win
    end
  end

  return nil
end

local function open_terminal()
  vim.cmd('botright split')
  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_height(win, terminal.height)

  if is_terminal_buffer(terminal.buf) then
    vim.api.nvim_win_set_buf(win, terminal.buf)
  else
    vim.cmd('terminal')
    terminal.buf = vim.api.nvim_get_current_buf()
    vim.bo[terminal.buf].bufhidden = 'hide'
    vim.bo[terminal.buf].swapfile = false
    vim.wo[win].number = false
    vim.wo[win].relativenumber = false
    vim.wo[win].signcolumn = 'no'
  end

  vim.cmd('startinsert')
end

local function toggle_terminal()
  local win = find_terminal_window()

  if win ~= nil then
    vim.api.nvim_win_hide(win)
    return
  end

  open_terminal()
end

vim.keymap.set({ 'n', 't' }, '<F12>', function()
  toggle_terminal()
end, {
  desc = 'Toggle terminal',
})

vim.keymap.set('n', '<leader>t', function()
  toggle_terminal()
end, {
  desc = 'Toggle terminal',
})
