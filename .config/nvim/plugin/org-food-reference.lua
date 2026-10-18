local pick = require("mini.pick")

local reference_file =
    vim.fn.expand("~/org/food-diary/food-reference.org")

local function get_foods()
  if vim.fn.filereadable(reference_file) == 0 then
    vim.notify("Food reference file not found", vim.log.levels.WARN)
    return {}
  end

  local lines = vim.fn.readfile(reference_file)
  local foods = {}
  local heading = nil

  for _, line in ipairs(lines) do
    -- Remember the most recent Org heading
    local title = line:match("^%*+%s+(.+)$")

    if title then
      heading = title
    end

    -- Find the CUSTOM_ID associated with that heading
    local id = line:match("^%s*:CUSTOM_ID:%s*(%S+)")

    if id and heading then
      table.insert(foods, {
        text = heading,
        id = id,
      })
    end
  end

  return foods
end

local function insert_link(food)
  local link = string.format(
    "[[#%s][%s]]",
    food.id,
    food.text
  )

  -- The picker has its own window.
  -- Get the window where it was opened.
  local state = pick.get_picker_state()
  local target = state.windows.target

  vim.api.nvim_win_call(target, function()
    local buffer = vim.api.nvim_get_current_buf()
    local cursor = vim.api.nvim_win_get_cursor(0)

    local row = cursor[1] - 1
    local col = cursor[2]

    vim.api.nvim_buf_set_text(
      buffer,
      row, col,
      row, col,
      { link }
    )

    vim.api.nvim_win_set_cursor(
      0,
      { cursor[1], col + #link }
    )
  end)
end

local function pick_food()
  local foods = get_foods()

  if #foods == 0 then
    vim.notify("No food references found", vim.log.levels.WARN)
    return
  end

  pick.start({
    source = {
      name = "Food Reference",
      items = foods,
      choose = insert_link,
    },
  })
end

vim.keymap.set("n", "<leader>fr", pick_food, {
  desc = "Insert food reference",
})
