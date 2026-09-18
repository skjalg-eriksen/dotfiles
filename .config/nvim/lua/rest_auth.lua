local M = {}

local access_tokens = {}
local http_cursor_rows = {}
local last_http_buffer
local pending_captures = {}
local session_variables = {}

local fake_words = {
  'amber',
  'atlas',
  'birch',
  'coral',
  'ember',
  'fjord',
  'harbor',
  'indigo',
  'meadow',
  'summit',
}

local fake_first_names = {
  'Ada',
  'Amelia',
  'Frida',
  'Grace',
  'Iris',
  'Linus',
  'Maya',
  'Noah',
  'Oscar',
  'Sofia',
}

local function fail(message)
  error('rest.nvim authentication: ' .. message, 0)
end

local function system(command, timeout)
  local result = vim.system(command, { text = true }):wait(timeout or 30000)
  if result.code ~= 0 then
    return nil, vim.trim(result.stderr or result.stdout or 'command failed')
  end
  return vim.trim(result.stdout or '')
end

local function base64_url(value)
  return vim.base64.encode(value):gsub('%+', '-'):gsub('/', '_'):gsub('=+$', '')
end

local function random_value(bytes)
  local value, err = system({ 'openssl', 'rand', '-base64', tostring(bytes) }, 5000)
  if not value then
    fail('could not generate a secure PKCE value: ' .. err)
  end
  return value:gsub('%+', '-'):gsub('/', '_'):gsub('=', ''):gsub('%s', '')
end

local function sha256(value)
  local hex = vim.fn.sha256(value)
  return hex:gsub('..', function(pair)
    return string.char(tonumber(pair, 16))
  end)
end

local function url_encode(value)
  return value:gsub('\n', '\r\n'):gsub('([^%w%-._~])', function(char)
    return string.format('%%%02X', string.byte(char))
  end)
end

local function parse_query(target)
  local query = target:match('%?(.*)') or ''
  local values = {}

  for key, value in query:gmatch('([^&=?]+)=([^&]*)') do
    values[key] = value:gsub('%+', ' '):gsub('%%(%x%x)', function(hex)
      return string.char(tonumber(hex, 16))
    end)
  end

  return values
end

local function current_http_buffer()
  local current = vim.api.nvim_get_current_buf()
  if vim.bo[current].filetype == 'http' then
    return current
  end

  if last_http_buffer and vim.api.nvim_buf_is_valid(last_http_buffer) then
    return last_http_buffer
  end
end

local function http_lines(bufnr)
  return vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
end

local function find_auth_file(bufnr)
  local filename = vim.api.nvim_buf_get_name(bufnr)
  if filename == '' then
    return
  end

  return vim.fs.find('resterm.auth.http', {
    path = vim.fs.dirname(filename),
    upward = true,
    type = 'file',
  })[1]
end

local function parse_variable_directives(lines, directive)
  local variables = {}

  for _, line in ipairs(lines) do
    local name, value = line:match('^%s*#%s*@' .. directive .. '%s+([%w_.-]+)%s+(.+)%s*$')
    if name then
      variables[name] = value
    end
  end

  return variables
end

local function variable_defaults(bufnr)
  local defaults = {}
  local auth_file = find_auth_file(bufnr)
  if auth_file then
    defaults = parse_variable_directives(vim.fn.readfile(auth_file), 'global')
  end

  return vim.tbl_extend('force', defaults, parse_variable_directives(http_lines(bufnr), 'file'))
end

local function variable_names(bufnr)
  local names = variable_defaults(bufnr)
  for name in pairs(session_variables) do
    names[name] = true
  end

  for _, line in ipairs(http_lines(bufnr)) do
    for name in line:gmatch('{{%s*([^}$][^}]*)%s*}}') do
      names[vim.trim(name)] = true
    end
  end

  local result = vim.tbl_keys(names)
  table.sort(result)
  return result
end

local function prepare_variables(bufnr)
  local defaults = variable_defaults(bufnr)
  for name, value in pairs(defaults) do
    vim.env[name] = session_variables[name] or value
  end
  for name, value in pairs(session_variables) do
    vim.env[name] = value
  end
end

local function random_item(values)
  return values[math.random(#values)]
end

local function random_string(length)
  local chars = 'abcdefghijklmnopqrstuvwxyz0123456789'
  local result = {}
  for _ = 1, length do
    local index = math.random(#chars)
    table.insert(result, chars:sub(index, index))
  end
  return table.concat(result)
end

local function quoted_arguments(value)
  local result = {}
  for argument in value:gmatch([['([^']*)']]) do
    table.insert(result, argument)
  end
  for argument in value:gmatch([["([^"]*)"]]) do
    table.insert(result, argument)
  end
  return result
end

local function fake_value(name)
  if name == '$fake.word' then
    return random_item(fake_words)
  elseif name == '$fake.firstName' then
    return random_item(fake_first_names)
  elseif name == '$fake.sentence' or name == '$fake.title' then
    local count = name == '$fake.title' and 3 or 7
    local words = {}
    for _ = 1, count do
      table.insert(words, random_item(fake_words))
    end
    local value = table.concat(words, ' ')
    return value:sub(1, 1):upper() .. value:sub(2) .. (name == '$fake.sentence' and '.' or '')
  end

  local min, max = name:match('^%$randomInt%((%-?%d+),%s*(%-?%d+)%)$')
  if min then
    return tostring(math.random(tonumber(min), tonumber(max)))
  end

  local length = name:match('^%$randomString%((%d+)%)$')
  if length then
    return random_string(tonumber(length))
  end

  if name:match('^%$randomChoice%(') then
    local choices = quoted_arguments(name)
    if #choices > 0 then
      return random_item(choices)
    end
  end
end

local function register_dynamic_variables(bufnr)
  local dynamic_variables = require('rest-nvim.config').custom_dynamic_variables

  for _, line in ipairs(http_lines(bufnr)) do
    for name in line:gmatch('{{%s*(%$.-)%s*}}') do
      local dynamic_name = vim.trim(name)
      if fake_value(dynamic_name) ~= nil then
        dynamic_variables[dynamic_name] = function()
          return fake_value(dynamic_name)
        end
      end
    end
  end
end

local function variable_under_cursor()
  local line = vim.api.nvim_get_current_line()
  local column = vim.api.nvim_win_get_cursor(0)[2] + 1

  local start = 1
  while true do
    local first, last, name = line:find('{{%s*([^}]+)%s*}}', start)
    if not first then
      return
    end
    if column >= first and column <= last then
      name = vim.trim(name)
      return not vim.startswith(name, '$') and name or nil
    end
    start = last + 1
  end
end

local function set_variable(name, value)
  session_variables[name] = value
  vim.env[name] = value
  vim.notify(('%s = %s'):format(name, value), vim.log.levels.INFO, {
    title = 'rest.nvim variables',
  })
end

local function prompt_variable()
  local bufnr = current_http_buffer()
  if not bufnr then
    fail('variable overrides can only be set from an HTTP buffer')
  end

  local function prompt_value(name)
    local clipboard = vim.fn.getreg('+')
    vim.ui.input({
      prompt = name .. ': ',
      default = clipboard ~= '' and clipboard or session_variables[name] or vim.env[name],
    }, function(value)
      if value then
        set_variable(name, value)
      end
    end)
  end

  local name_under_cursor = variable_under_cursor()
  if name_under_cursor then
    prompt_value(name_under_cursor)
    return
  end

  vim.ui.input({
    prompt = 'Variable: ',
    completion = 'customlist,v:lua.RestNvimVariableComplete',
  }, function(name)
    if not name or name == '' then
      return
    end
    prompt_value(name)
  end)
end

local function request_section_lines(bufnr)
  local lines = http_lines(bufnr)
  local cursor_row = http_cursor_rows[bufnr] or 1
  local first = cursor_row
  while first > 1 and not lines[first]:match('^%s*###') do
    first = first - 1
  end

  local last = cursor_row + 1
  while last <= #lines and not lines[last]:match('^%s*###') do
    last = last + 1
  end

  return vim.list_slice(lines, first, last - 1)
end

local function capture_directives(bufnr)
  local captures = {}
  for _, line in ipairs(request_section_lines(bufnr)) do
    local name, path =
      line:match('^%s*#%s*@capture%s+global%s+([%w_.-]+)%s+' .. '{{response%.json%.([%w_.%[%]-]+)}}%s*$')
    if name then
      table.insert(captures, { name = name, path = path })
    end
  end
  return captures
end

local function json_path(value, path)
  for part in path:gmatch('[^.]+') do
    local key, index = part:match('^([%w_-]+)%[(%d+)]$')
    if key then
      value = type(value) == 'table' and value[key] or nil
      value = type(value) == 'table' and value[tonumber(index) + 1] or nil
    else
      value = type(value) == 'table' and value[part] or nil
    end
    if value == nil then
      return
    end
  end
  return value
end

local function apply_captures(response)
  if #pending_captures == 0 then
    return
  end

  local captures = pending_captures
  pending_captures = {}
  local ok, body = pcall(vim.json.decode, response.body or '')
  if not ok then
    vim.notify(
      'Could not capture response variables because the body is not valid JSON',
      vim.log.levels.WARN,
      { title = 'rest.nvim' }
    )
    return
  end

  for _, capture in ipairs(captures) do
    local value = json_path(body, capture.path)
    if value == nil then
      vim.notify(
        ('Could not capture %s: response.json.%s was not found'):format(capture.name, capture.path),
        vim.log.levels.WARN,
        { title = 'rest.nvim' }
      )
    elseif type(value) == 'table' then
      set_variable(capture.name, vim.json.encode(value))
    else
      set_variable(capture.name, tostring(value))
    end
  end
end

local function directive_value(line, key)
  return line:match(key .. '="([^"]+)"') or line:match(key .. '=([^%s]+)')
end

local function read_oauth_config(path)
  for _, line in ipairs(vim.fn.readfile(path)) do
    if line:match('^%s*#%s*@auth%s+global%s+oauth2%s+') then
      local config = {
        auth_url = directive_value(line, 'auth_url'),
        token_url = directive_value(line, 'token_url'),
        client_id = directive_value(line, 'client_id'),
        scope = directive_value(line, 'scope'),
        cache_key = directive_value(line, 'cache_key'),
      }

      for _, key in ipairs({ 'auth_url', 'token_url', 'client_id', 'scope' }) do
        if not config[key] then
          fail(('missing %s in %s'):format(key, path))
        end
      end

      config.cache_key = config.cache_key or config.client_id
      return config
    end
  end
end

local function keychain_service(config)
  return 'rest.nvim.oauth.' .. config.cache_key
end

local function read_refresh_token(config)
  local token = system({
    'security',
    'find-generic-password',
    '-a',
    config.client_id,
    '-s',
    keychain_service(config),
    '-w',
  }, 5000)
  return token
end

local function save_refresh_token(config, token)
  local _, err = system({
    'security',
    'add-generic-password',
    '-U',
    '-a',
    config.client_id,
    '-s',
    keychain_service(config),
    '-w',
    token,
  }, 5000)

  if err then
    vim.notify(
      'The OAuth refresh token could not be saved to macOS Keychain: ' .. err,
      vim.log.levels.WARN,
      { title = 'rest.nvim' }
    )
  end
end

local function request_token(config, fields)
  local command = {
    'curl',
    '--silent',
    '--show-error',
    '--request',
    'POST',
    '--header',
    'Content-Type: application/x-www-form-urlencoded',
  }

  for key, value in pairs(fields) do
    vim.list_extend(command, { '--data-urlencode', key .. '=' .. value })
  end
  table.insert(command, config.token_url)

  local output, err = system(command)
  if not output then
    return nil, err
  end

  local ok, response = pcall(vim.json.decode, output)
  if not ok or type(response) ~= 'table' then
    return nil, 'the token endpoint returned an invalid response'
  end
  if response.error then
    return nil, response.error_description or response.error
  end
  if not response.access_token then
    return nil, 'the token endpoint did not return an access token'
  end

  return response
end

local function listen_for_callback()
  local server = assert(vim.uv.new_tcp())
  assert(server:bind('127.0.0.1', 0))
  local port = assert(server:getsockname()).port
  local callback
  local callback_error

  server:listen(1, function(err)
    if err then
      callback_error = err
      return
    end

    local client = assert(vim.uv.new_tcp())
    server:accept(client)
    local request = ''

    client:read_start(function(read_err, chunk)
      if read_err then
        callback_error = read_err
      elseif chunk then
        request = request .. chunk
      end

      if callback_error or request:find('\r\n\r\n', 1, true) then
        client:read_stop()
        local target = request:match('^GET%s+([^%s]+)')
        callback = target and parse_query(target) or {}
        local body = callback_error and 'Authentication failed. You can close this window.'
          or 'Authentication complete. You can close this window and return to Neovim.'
        local response = table.concat({
          'HTTP/1.1 200 OK',
          'Content-Type: text/plain; charset=utf-8',
          'Connection: close',
          'Content-Length: ' .. #body,
          '',
          body,
        }, '\r\n')

        client:write(response, function()
          client:shutdown(function()
            client:close()
          end)
        end)
        server:close()
      end
    end)
  end)

  return {
    port = port,
    wait = function()
      local completed = vim.wait(300000, function()
        return callback ~= nil or callback_error ~= nil
      end, 50)

      if not server:is_closing() then
        server:close()
      end
      if not completed then
        fail('timed out waiting for the browser sign-in')
      end
      if callback_error then
        fail('OAuth callback failed: ' .. callback_error)
      end
      return callback
    end,
  }
end

local function interactive_token(config)
  local verifier = random_value(64)
  local state = random_value(32)
  local listener = listen_for_callback()
  local redirect_uri = ('http://localhost:%d/oauth/callback'):format(listener.port)
  local scope = config.scope
  if not (' ' .. scope .. ' '):match('%soffline_access%s') then
    scope = scope .. ' offline_access'
  end

  local params = {
    client_id = config.client_id,
    code_challenge = base64_url(sha256(verifier)),
    code_challenge_method = 'S256',
    redirect_uri = redirect_uri,
    response_mode = 'query',
    response_type = 'code',
    scope = scope,
    state = state,
  }
  local query = {}
  for key, value in pairs(params) do
    table.insert(query, url_encode(key) .. '=' .. url_encode(value))
  end

  local _, open_err = vim.ui.open(config.auth_url .. '?' .. table.concat(query, '&'))
  if open_err then
    fail('could not open the browser: ' .. open_err)
  end

  vim.notify('Complete the Entra sign-in in your browser', vim.log.levels.INFO, {
    title = 'rest.nvim',
  })

  local callback = listener.wait()
  if callback.error then
    fail(callback.error_description or callback.error)
  end
  if callback.state ~= state then
    fail('OAuth callback state did not match')
  end
  if not callback.code then
    fail('OAuth callback did not include an authorization code')
  end

  local response, err = request_token(config, {
    client_id = config.client_id,
    code = callback.code,
    code_verifier = verifier,
    grant_type = 'authorization_code',
    redirect_uri = redirect_uri,
    scope = scope,
  })
  if not response then
    fail(err)
  end
  return response
end

local function access_token(config)
  local cached = access_tokens[config.cache_key]
  if cached and cached.expires_at > os.time() + 60 then
    return cached.value
  end

  local refresh_token = read_refresh_token(config)
  local response
  if refresh_token then
    response = request_token(config, {
      client_id = config.client_id,
      grant_type = 'refresh_token',
      refresh_token = refresh_token,
      scope = config.scope .. ' offline_access',
    })
  end

  if not response then
    response = interactive_token(config)
  end
  if response.refresh_token then
    save_refresh_token(config, response.refresh_token)
  end

  access_tokens[config.cache_key] = {
    expires_at = os.time() + (tonumber(response.expires_in) or 300),
    value = response.access_token,
  }
  return response.access_token
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

function M.setup()
  local group = vim.api.nvim_create_augroup('nm_rest_auth', { clear = true })

  vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'CursorMoved' }, {
    group = group,
    pattern = '*.http',
    callback = function(args)
      last_http_buffer = args.buf
      if vim.api.nvim_get_current_buf() == args.buf then
        http_cursor_rows[args.buf] = vim.api.nvim_win_get_cursor(0)[1]
      end
      prepare_variables(args.buf)
      register_dynamic_variables(args.buf)
    end,
  })

  vim.api.nvim_create_autocmd('User', {
    group = group,
    pattern = 'RestRequestPre',
    callback = function()
      local req = _G.rest_request
      local bufnr = current_http_buffer()
      if not req or not bufnr then
        fail('could not identify the source HTTP buffer')
      end

      pending_captures = capture_directives(bufnr)
      apply_base_url(req, bufnr)
      if req.headers.authorization then
        return
      end

      local auth_file = find_auth_file(bufnr)
      if not auth_file then
        return
      end

      local config = read_oauth_config(auth_file)
      if config then
        req.headers.authorization = { 'Bearer ' .. access_token(config) }
      end
    end,
  })

  vim.api.nvim_create_autocmd('User', {
    group = group,
    pattern = 'RestResponsePre',
    callback = function()
      if _G.rest_response then
        apply_captures(_G.rest_response)
      end
    end,
  })

  _G.RestNvimVariableComplete = function()
    local bufnr = current_http_buffer()
    return bufnr and variable_names(bufnr) or {}
  end

  vim.api.nvim_create_user_command('RestSet', function(opts)
    local name, value = opts.args:match('^(%S+)%s+(.+)$')
    if not name then
      vim.notify('Usage: RestSet <name> <value>', vim.log.levels.WARN, {
        title = 'rest.nvim variables',
      })
      return
    end
    set_variable(name, value)
  end, {
    nargs = '+',
    complete = function()
      local bufnr = current_http_buffer()
      return bufnr and variable_names(bufnr) or {}
    end,
    desc = 'Set a rest.nvim session variable',
  })

  vim.api.nvim_create_user_command('RestUnset', function(opts)
    session_variables[opts.args] = nil
    vim.env[opts.args] = nil
    local bufnr = current_http_buffer()
    if bufnr then
      prepare_variables(bufnr)
    end
  end, {
    nargs = 1,
    complete = function()
      return vim.tbl_keys(session_variables)
    end,
    desc = 'Clear a rest.nvim session variable override',
  })

  M.prompt_variable = prompt_variable
end

return M
