local M = {}

M.namespace = vim.api.nvim_create_namespace('jumpmotion')

function M.setup_highlights()
  vim.api.nvim_set_hl(0, 'JumpMotionMatch', { link = 'Search', default = true })
  vim.api.nvim_set_hl(0, 'JumpMotionLabel', { link = 'IncSearch', default = true })
  vim.api.nvim_set_hl(0, 'JumpMotionDim', { link = 'Comment', default = true })
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
    vim.api.nvim_buf_set_extmark(bufnr, M.namespace, target.row, target.col, {
      -- Inline text at the match start places the badge to its left. It is
      -- legible at end-of-line and leaves the remaining query text visible.
      virt_text = { { '[' .. labels[target.id] .. ']', 'JumpMotionLabel' } },
      virt_text_pos = 'inline',
      priority = 201,
    })
  end
  -- getcharstr() keeps this Lua call on the stack. Force the decorations onto
  -- the screen before waiting for the next key instead of waiting for return.
  vim.cmd('redraw')
end

return M
