local M = {}

local faker = require('nvim-faker.faker-cli')

local faker_providers = {
  adjective = 'word adjective',
  animal = 'animal type',
  city = 'location city',
  color = 'color human',
  company = 'company name',
  country = 'location country',
  email = 'internet email',
  firstName = 'person firstName',
  fullName = 'person fullName',
  jobTitle = 'person jobTitle',
  lastName = 'person lastName',
  noun = 'word noun',
  petName = 'animal petName',
  product = 'commerce productName',
  sentence = 'lorem sentence',
  streetAddress = 'location streetAddress',
  title = 'lorem words 3',
  url = 'internet url',
  uuid = 'string uuid',
  verb = 'word verb',
  word = 'word sample',
}

local faker_commands = {}
local faker_names = {}
for name, command in pairs(faker_providers) do
  local canonical_name = '$faker.' .. name
  faker_commands[canonical_name] = command
  faker_commands['$fake.' .. name] = command
  table.insert(faker_names, canonical_name)
end
table.sort(faker_names)

local function fake(command)
  local value, err = faker.execute_faker_cli_command(command)
  if not value then
    error('faker.nvim: ' .. (err or 'failed to generate a value'), 0)
  end
  return vim.trim(value)
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

function M.generate(name)
  if faker_commands[name] then
    return fake(faker_commands[name])
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

local function supports(name)
  return faker_commands[name] ~= nil
    or name:match('^%$randomInt%((%-?%d+),%s*(%-?%d+)%)$') ~= nil
    or name:match('^%$randomString%((%d+)%)$') ~= nil
    or name:match('^%$randomChoice%(') ~= nil
end

function M.completion_items(prefix)
  return vim
    .iter(faker_names)
    :filter(function(name)
      return vim.startswith(name, prefix)
    end)
    :map(function(name)
      return {
        word = name,
        abbr = name,
        kind = 'Variable',
        menu = '[faker.nvim]',
      }
    end)
    :totable()
end

function M.complete()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local before_cursor = vim.api.nvim_get_current_line():sub(1, cursor[2])
  local start_column, _, prefix = before_cursor:find('(%$[%a%.]*)$')
  if not prefix or not vim.startswith(prefix, '$f') then
    return
  end

  local items = M.completion_items(prefix)
  if #items > 0 then
    vim.fn.complete(start_column, items)
  end
end

function M.register(bufnr)
  local dynamic_variables = require('rest-nvim.config').custom_dynamic_variables
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  for _, line in ipairs(lines) do
    for name in line:gmatch('{{%s*(%$.-)%s*}}') do
      local dynamic_name = vim.trim(name)
      if supports(dynamic_name) then
        dynamic_variables[dynamic_name] = function()
          return M.generate(dynamic_name)
        end
      end
    end
  end
end

return M
