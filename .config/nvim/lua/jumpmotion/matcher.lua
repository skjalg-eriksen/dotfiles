local M = {}

local function visible_rows(winid)
  -- A closed fold occupies one screen row but its concealed buffer lines do
  -- not. Exclude those lines rather than treating the w0/w$ range as wholly
  -- visible.
  return vim.api.nvim_win_call(winid, function()
    local first, last = vim.fn.line('w0'), vim.fn.line('w$')
    local rows = {}
    for line = first, last do
      if vim.fn.foldclosed(line) == -1 then table.insert(rows, line - 1) end
    end
    return rows
  end)
end

-- Find literal, possibly overlapping matches in the portion of the buffer that
-- is actually on screen. Rows and columns use Neovim's 0-based coordinates.
function M.find(bufnr, winid, query, cursor)
  if query == '' then return {} end
  local rows = visible_rows(winid)
  local matches = {}
  for _, row in ipairs(rows) do
    local line = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1]
    local start = 1
    while true do
      local from, to = string.find(line, query, start, true)
      if not from then break end
      local col = from - 1
      if row ~= cursor[1] - 1 or col ~= cursor[2] then
        table.insert(matches, { row = row, col = col, end_col = to, id = string.format('%d:%d', row, col) })
      end
      start = from + 1 -- retain overlapping literal occurrences
    end
  end
  return matches
end

return M
