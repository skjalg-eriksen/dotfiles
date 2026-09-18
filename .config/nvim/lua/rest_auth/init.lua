local M = {}

local fakes = require('rest_auth.fakes')
local oauth = require('rest_auth.oauth')
local variables = require('rest_auth.variables')

local cursor_rows = {}
local last_http_buffer

local function current_buffer()
  local current = vim.api.nvim_get_current_buf()
  if vim.bo[current].filetype == 'http' then
    return current
  end
  if last_http_buffer and vim.api.nvim_buf_is_valid(last_http_buffer) then
    return last_http_buffer
  end
end

local function apply_base_url(req, bufnr)
  if req.url:match('^[%w+.-]+://') then
    return
  end

  for _, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, 50, false)) do
    local base_url = line:match('^%s*#%s*@setting%s+base%-url%s+(.+)%s*$')
    if base_url then
      req.url = base_url:gsub('/+$', '') .. '/' .. req.url:gsub('^/+', '')
      return
    end
  end
end

function M.prompt_variable()
  local bufnr = current_buffer()
  if not bufnr then
    error('rest.nvim variables can only be set from an HTTP buffer', 0)
  end
  variables.prompt(bufnr)
end

function M.setup()
  local group = vim.api.nvim_create_augroup('nm_rest_auth', { clear = true })
  variables.setup(current_buffer)

  vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'CursorMoved' }, {
    group = group,
    pattern = '*.http',
    callback = function(args)
      last_http_buffer = args.buf
      if vim.api.nvim_get_current_buf() == args.buf then
        cursor_rows[args.buf] = vim.api.nvim_win_get_cursor(0)[1]
      end
      variables.prepare(args.buf)
      fakes.register(args.buf)
    end,
  })

  vim.api.nvim_create_autocmd('User', {
    group = group,
    pattern = 'RestRequestPre',
    callback = function()
      local req = _G.rest_request
      local bufnr = current_buffer()
      if not req or not bufnr then
        error('rest.nvim could not identify the source HTTP buffer', 0)
      end

      variables.prepare_captures(bufnr, cursor_rows[bufnr] or 1)
      apply_base_url(req, bufnr)
      oauth.apply(req, variables.find_auth_file(bufnr))
    end,
  })

  vim.api.nvim_create_autocmd('User', {
    group = group,
    pattern = 'RestResponsePre',
    callback = function()
      if _G.rest_response then
        variables.apply_captures(_G.rest_response)
      end
    end,
  })
end

return M
