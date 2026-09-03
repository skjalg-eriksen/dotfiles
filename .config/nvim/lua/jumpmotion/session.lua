local matcher = require('jumpmotion.matcher')
local labeler = require('jumpmotion.labels')
local render = require('jumpmotion.render')
local M = {}

local function is_backspace(key)
  return key == vim.keycode('<BS>') or key == vim.keycode('<C-h>') or key == '\b'
end
local function is_escape(key) return key == vim.keycode('<Esc>') or key == '\27' end
local function is_label_mode_key(key) return key == vim.keycode('<CR>') or key == '\r' end
local function is_printable(key) return #key > 0 and key:byte(1) >= 32 and not key:find('[\128-\255]') end
local function smartcase_enabled(config)
  if config.smartcase == nil then return vim.o.ignorecase and vim.o.smartcase end
  return config.smartcase
end

function M.start(config)
  local winid, bufnr = vim.api.nvim_get_current_win(), vim.api.nvim_get_current_buf()
  local session = {
    bufnr = bufnr, winid = winid, original_cursor = vim.api.nvim_win_get_cursor(winid),
    query = '', matches = {}, labels = {}, assigned_labels = {}, label_input = nil,
    smartcase = smartcase_enabled(config),
  }
  local function cleanup()
    render.clear(session.bufnr)
    vim.cmd('redraw')
  end
  local function cancel()
    if vim.api.nvim_win_is_valid(session.winid) then vim.api.nvim_win_set_cursor(session.winid, session.original_cursor) end
  end
  local function finish(target)
    if target and vim.api.nvim_win_is_valid(session.winid) then
      vim.api.nvim_win_set_cursor(session.winid, { target.row + 1, target.col })
    end
  end
  local function refresh()
    session.matches = matcher.find(session.bufnr, session.winid, session.query, session.original_cursor, session.smartcase)
    session.labels, session.assigned_labels = labeler.assign(session.matches, config.labels, session.assigned_labels)
    render.draw(session.bufnr, session.matches, session.labels)
  end

  local ok, err = xpcall(function()
    while vim.api.nvim_win_is_valid(session.winid) and vim.api.nvim_get_current_win() == session.winid do
      local key = vim.fn.getcharstr()
      if is_escape(key) then cancel(); return end
      if is_backspace(key) then
        if session.label_input ~= nil then
          -- Backspace first leaves explicit label mode without changing query.
          session.label_input = nil
        elseif #session.query > 0 then
          session.query = session.query:sub(1, -2)
          refresh()
        end
      elseif is_label_mode_key(key) and #session.matches > 0 then
        -- Explicit label mode resolves query/label collisions. An empty string
        -- is intentional: the following printable key is label character one.
        session.label_input = ''
      elseif is_printable(key) then
        if session.label_input then
          local target, has_prefix = labeler.target_for_input(session.matches, session.labels, session.label_input .. key)
          if target then finish(target); return end
          if has_prefix then session.label_input = session.label_input .. key else session.label_input = nil end
        else
          -- v1 ambiguity policy, isolated here: a viable refinement wins.
          local candidate = session.query .. key
          local candidate_matches = matcher.find(session.bufnr, session.winid, candidate, session.original_cursor, session.smartcase)
          if #candidate_matches > 0 then
            session.query, session.matches = candidate, candidate_matches
            session.labels, session.assigned_labels = labeler.assign(session.matches, config.labels, session.assigned_labels)
            if config.auto_jump and #session.matches == 1 then finish(session.matches[1]); return end
            render.draw(session.bufnr, session.matches, session.labels)
          else
            local target, has_prefix = labeler.target_for_input(session.matches, session.labels, key)
            if target then finish(target); return end
            if has_prefix then session.label_input = key end
          end
        end
      end
    end
  end, debug.traceback)
  cleanup()
  if not ok then vim.schedule(function() vim.notify('JumpMotion failed: ' .. err, vim.log.levels.ERROR) end) end
end

return M
