local M = {}

M.namespace = vim.api.nvim_create_namespace('jumpmotion')

function M.setup_highlights(highlights)
  for group, spec in pairs(highlights) do
    vim.api.nvim_set_hl(0, group, spec)
  end
end

function M.clear(bufnr)
  if vim.api.nvim_buf_is_valid(bufnr) then vim.api.nvim_buf_clear_namespace(bufnr, M.namespace, 0, -1) end
end

function M.draw(bufnr, matches, labels)
  M.clear(bufnr)
  for _, target in ipairs(matches) do
    vim.api.nvim_buf_set_extmark(bufnr, M.namespace, target.row, target.col, {
      end_col = target.end_col, hl_group = 'JumpMotionMatch', priority = 200,
    })
    local badge = '[' .. labels[target.id] .. ']'
    -- A fixed window-column badge overlays instead of inserting text, so a
    -- dense set of matches cannot reflow source lines. Prefer the columns just
    -- left of the match; at column zero it overlays the match's beginning.
    local match_win_col = vim.fn.virtcol({ target.row + 1, target.col + 1 }) - 1
    local badge_win_col = math.max(0, match_win_col - vim.fn.strdisplaywidth(badge))
    vim.api.nvim_buf_set_extmark(bufnr, M.namespace, target.row, target.col, {
      virt_text = { { badge, 'JumpMotionLabel' } },
      virt_text_pos = 'overlay',
      virt_text_win_col = badge_win_col,
      priority = 201,
    })
  end
  -- getcharstr() keeps this Lua call on the stack. Force the decorations onto
  -- the screen before waiting for the next key instead of waiting for return.
  vim.cmd('redraw')
end

return M
