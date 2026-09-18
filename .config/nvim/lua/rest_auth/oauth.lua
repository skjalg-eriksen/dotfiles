local M = {}

local access_tokens = {}

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

local function directive_value(line, key)
  return line:match(key .. '="([^"]+)"') or line:match(key .. '=([^%s]+)')
end

local function read_config(path)
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
  return system({
    'security',
    'find-generic-password',
    '-a',
    config.client_id,
    '-s',
    keychain_service(config),
    '-w',
  }, 5000)
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
  elseif response.error then
    return nil, response.error_description or response.error
  elseif not response.access_token then
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
      elseif callback_error then
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
  vim.notify('Complete the Entra sign-in in your browser', vim.log.levels.INFO, { title = 'rest.nvim' })

  local callback = listener.wait()
  if callback.error then
    fail(callback.error_description or callback.error)
  elseif callback.state ~= state then
    fail('OAuth callback state did not match')
  elseif not callback.code then
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

function M.apply(req, auth_file)
  if req.headers.authorization or not auth_file then
    return
  end

  local config = read_config(auth_file)
  if config then
    req.headers.authorization = { 'Bearer ' .. access_token(config) }
  end
end

return M
