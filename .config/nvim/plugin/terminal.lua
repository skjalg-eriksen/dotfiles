local terminal = {
  buf = nil,
  height = 12,
  tmux_pane = nil,
  tmux_host_pane = nil,
  tmux_host_window = nil,
}

local function in_tmux()
  return vim.env.TMUX ~= nil and vim.env.TMUX ~= ''
end

local function tmux(command)
  local output = vim.fn.system(vim.list_extend({ 'tmux' }, command))
  if vim.v.shell_error ~= 0 then
    return nil
  end

  return output:gsub('%s+$', '')
end

local function tmux_pane_exists(pane)
  return pane ~= nil
      and tmux({ 'display-message', '-p', '-t', pane, '#{pane_id}' }) == pane
end

local function tmux_pane_window(pane)
  return tmux({ 'display-message', '-p', '-t', pane, '#{window_id}' })
end

local function toggle_tmux_terminal()
  if tmux_pane_exists(terminal.tmux_pane) then
    tmux({
      'set-option',
      '-p',
      '-t', terminal.tmux_pane,
      '@nvimTerm', '1',
    })

    if tmux_pane_window(terminal.tmux_pane) == terminal.tmux_host_window then
      -- tmux cannot hide a pane in-place, so keep the live shell in a parked
      -- window until it is toggled open again.
      tmux({ 'break-pane', '-d', '-s', terminal.tmux_pane })
    elseif tmux_pane_exists(terminal.tmux_host_pane) then
      tmux({
        'join-pane',
        '-v',
        '-l', tostring(terminal.height),
        '-s', terminal.tmux_pane,
        '-t', terminal.tmux_host_pane,
      })
    end

    return
  end

  terminal.tmux_host_pane = tmux({ 'display-message', '-p', '#{pane_id}' })
  terminal.tmux_host_window = tmux_pane_window(terminal.tmux_host_pane)
  terminal.tmux_pane = tmux({
    'split-window',
    '-v',
    '-l', tostring(terminal.height),
    '-P',
    '-F', '#{pane_id}',
  })

  if terminal.tmux_pane ~= nil then
    tmux({
      'select-pane',
      '-t', terminal.tmux_pane,
      '-T', 'nvimTerm',
    })
    tmux({
      'set-option',
      '-p',
      '-t', terminal.tmux_pane,
      '@nvimTerm', '1',
    })
  end
end

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

local function focus_terminal_window(win)
  vim.api.nvim_set_current_win(win)
  vim.cmd('startinsert')
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
  if in_tmux() then
    toggle_tmux_terminal()
    return
  end

  local win = find_terminal_window()

  if win ~= nil then
    if vim.api.nvim_get_current_win() == win then
      vim.api.nvim_win_hide(win)
    else
      focus_terminal_window(win)
    end

    return
  end

  open_terminal()
end

vim.keymap.set({ 'n', 't' }, '<F12>', function()
  toggle_terminal()
end, {
  desc = 'Toggle terminal',
})

vim.keymap.set('t', '<C-[>', [[<C-\><C-n>]], {
  desc = 'Exit terminal mode',
})

vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], {
  desc = 'Exit terminal mode',
})

vim.keymap.set('n', '<leader>t', function()
  toggle_terminal()
end, {
  desc = 'Toggle terminal',
})
