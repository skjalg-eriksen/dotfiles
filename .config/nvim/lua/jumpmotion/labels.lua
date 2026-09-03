local M = {}

local function required_width(count, alphabet_size)
  local width, capacity = 1, alphabet_size
  while capacity < count do
    width, capacity = width + 1, capacity * alphabet_size
  end
  return width
end

local function encode(number, alphabet, width)
  local base, chars = #alphabet, {}
  for index = width, 1, -1 do
    chars[index] = alphabet:sub((number % base) + 1, (number % base) + 1)
    number = math.floor(number / base)
  end
  return table.concat(chars)
end

-- Query refinement only removes targets. Keeping this session table therefore
-- preserves labels both while narrowing and after backspacing. Fixed-width
-- codes are prefix-free when more than one label character is necessary.
function M.assign(matches, alphabet, assigned)
  if #alphabet == 0 then error('jumpmotion labels must not be empty') end
  assigned = assigned or {}
  local width = required_width(#matches, #alphabet)
  for index, target in ipairs(matches) do
    if not assigned[target.id] then assigned[target.id] = encode(index - 1, alphabet, width) end
  end
  local labels = {}
  for _, target in ipairs(matches) do labels[target.id] = assigned[target.id] end
  return labels, assigned
end

function M.target_for_input(matches, labels, input)
  local has_prefix = false
  for _, target in ipairs(matches) do
    local label = labels[target.id]
    if label == input then return target, false end
    if vim.startswith(label, input) then has_prefix = true end
  end
  return nil, has_prefix
end

return M
