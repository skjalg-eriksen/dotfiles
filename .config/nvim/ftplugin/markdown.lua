local function is_table_separator(line)
  local cells = vim.split(line, '|', { plain = true, trimempty = true })
  if #cells == 0 then
    return false
  end

  for _, cell in ipairs(cells) do
    if not cell:match('^%s*:?-+:?%s*$') then
      return false
    end
  end

  return true
end

local function is_table_row(line)
  local _, pipes = line:gsub('|', '')
  return pipes >= 1
end

local function table_bounds(row)
  local line_count = vim.api.nvim_buf_line_count(0)
  local start_row = row
  local end_row = row

  while start_row > 1 and is_table_row(vim.api.nvim_buf_get_lines(0, start_row - 2, start_row - 1, false)[1]) do
    start_row = start_row - 1
  end

  while end_row < line_count and is_table_row(vim.api.nvim_buf_get_lines(0, end_row, end_row + 1, false)[1]) do
    end_row = end_row + 1
  end

  for table_row = start_row, end_row do
    if is_table_separator(vim.api.nvim_buf_get_lines(0, table_row - 1, table_row, false)[1]) then
      return start_row, end_row
    end
  end
end

local function cell_start(line, column)
  local pipe = line:find('|', column + 1, true)
  if not pipe or line:sub(pipe + 1):match('^%s*$') then
    return
  end

  local next_column = pipe + 1
  while line:sub(next_column, next_column):match('%s') do
    next_column = next_column + 1
  end

  return next_column
end

local function next_cell()
  local row, column = unpack(vim.api.nvim_win_get_cursor(0))
  local bounds_start, bounds_end = table_bounds(row)
  if not bounds_start then
    return
  end

  local line = vim.api.nvim_get_current_line()
  local next_column = cell_start(line, column)
  if next_column then
    return row, next_column
  end

  for next_row = row + 1, bounds_end do
    local next_line = vim.api.nvim_buf_get_lines(0, next_row - 1, next_row, false)[1]
    if not is_table_separator(next_line) then
      local first_pipe = next_line:find('|', 1, true)
      if first_pipe then
        if next_line:sub(1, first_pipe - 1):match('^%s*$') then
          return next_row, cell_start(next_line, first_pipe - 1)
        end

        local first_content = next_line:find('%S')
        if first_content then
          return next_row, first_content
        end
      end
    end
  end
end

local function move_to_next_cell()
  local row, column = next_cell()
  if row and column then
    vim.api.nvim_win_set_cursor(0, { row, column - 1 })
    return true
  end
  return false
end

local function cell_starts(line)
  local starts = {}
  local first_pipe = line:find('|', 1, true)
  if not first_pipe then
    return starts
  end

  if line:sub(1, first_pipe - 1):match('^%s*$') then
    local first_cell = cell_start(line, 0)
    if first_cell then
      table.insert(starts, first_cell)
    end
  else
    local first_cell = line:find('%S')
    if first_cell then
      table.insert(starts, first_cell)
    end
  end

  local pipe = first_pipe
  while pipe do
    local start = cell_start(line, pipe)
    if start then
      table.insert(starts, start)
    end
    pipe = line:find('|', pipe + 1, true)
  end

  return starts
end

local function previous_cell()
  local row, column = unpack(vim.api.nvim_win_get_cursor(0))
  local bounds_start = table_bounds(row)
  if not bounds_start then
    return
  end

  local starts = cell_starts(vim.api.nvim_get_current_line())
  for index = #starts, 1, -1 do
    if starts[index] <= column + 1 then
      if index > 1 then
        return row, starts[index - 1]
      end
      break
    end
  end

  for previous_row = row - 1, bounds_start, -1 do
    local previous_line = vim.api.nvim_buf_get_lines(0, previous_row - 1, previous_row, false)[1]
    if not is_table_separator(previous_line) then
      local previous_starts = cell_starts(previous_line)
      if #previous_starts > 0 then
        return previous_row, previous_starts[#previous_starts]
      end
    end
  end
end

local function move_to_previous_cell()
  local row, column = previous_cell()
  if row and column then
    vim.api.nvim_win_set_cursor(0, { row, column - 1 })
    return true
  end
  return false
end

vim.keymap.set('n', '<Tab>', move_to_next_cell, {
  buffer = true,
  desc = 'Move to next Markdown table cell',
})

vim.keymap.set('n', '<S-Tab>', move_to_previous_cell, {
  buffer = true,
  desc = 'Move to previous Markdown table cell',
})

vim.keymap.set('i', '<Tab>', function()
  if vim.fn.pumvisible() == 1 then
    return '<C-n>'
  end

  if move_to_next_cell() then
    return ''
  end

  return '<Tab>'
end, {
  buffer = true,
  desc = 'Move to next Markdown table cell',
  expr = true,
})

vim.keymap.set('i', '<S-Tab>', function()
  if vim.fn.pumvisible() == 1 then
    return '<C-p>'
  end

  if move_to_previous_cell() then
    return ''
  end

  return '<S-Tab>'
end, {
  buffer = true,
  desc = 'Move to previous Markdown table cell',
  expr = true,
})
