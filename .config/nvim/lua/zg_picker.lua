local M = {}

local function parse_results(output)
  local hits = {}
  local current_file
  local pending_hit

  for line in output:gmatch('[^\r\n]+') do
    local file = line:match('^File: (.+)$')
    if file then
      current_file = file
    end

    local title = line:match('^%s*#%d+%s+(.+)%s+matchedBy=')
    if title and current_file then
      pending_hit = {
        path = current_file,
        title = title,
      }
    end

    local start_line, end_line = line:match('^%s*Range: (%d+)%-(%d+)')
    if pending_hit and start_line and end_line then
      pending_hit.start_line = tonumber(start_line)
      pending_hit.end_line = tonumber(end_line)
      table.insert(hits, pending_hit)
      pending_hit = nil
    end
  end

  return hits
end

local function full_path(cwd, path)
  if path:sub(1, 1) == '/' then
    return path
  end

  return vim.fs.joinpath(cwd, path)
end

local function open_picker(cwd)
  local source_win = vim.api.nvim_get_current_win()
  local ui = vim.api.nvim_list_uis()[1]
  local height = math.floor(ui.height * 0.7)
  local width = math.floor(ui.width * 0.9)
  local list_width = math.floor(width * 0.45)
  local row = math.floor((ui.height - height - 2) / 2)
  local col = math.floor((ui.width - width) / 2)
  local input_buf = vim.api.nvim_create_buf(false, true)
  local list_buf = vim.api.nvim_create_buf(false, true)
  local preview_buf = vim.api.nvim_create_buf(false, true)
  local input_win
  local list_win
  local preview_win
  local active_job
  local closed = false
  local query_id = 0
  local hits = {}
  local timer = vim.uv.new_timer()
  local selection_ns = vim.api.nvim_create_namespace('zg_picker_selection')

  for _, bufnr in ipairs({ input_buf, list_buf, preview_buf }) do
    vim.bo[bufnr].bufhidden = 'wipe'
    vim.bo[bufnr].buftype = 'nofile'
    vim.bo[bufnr].swapfile = false
  end

  input_win = vim.api.nvim_open_win(input_buf, true, {
    relative = 'editor',
    width = width,
    height = 1,
    row = row,
    col = col,
    style = 'minimal',
    border = 'rounded',
    title = ' Zvec search ',
  })
  list_win = vim.api.nvim_open_win(list_buf, false, {
    relative = 'editor',
    width = list_width,
    height = height,
    row = row + 3,
    col = col,
    style = 'minimal',
    border = 'rounded',
    title = ' Results ',
  })
  preview_win = vim.api.nvim_open_win(preview_buf, false, {
    relative = 'editor',
    width = width - list_width - 1,
    height = height,
    row = row + 3,
    col = col + list_width + 1,
    style = 'minimal',
    border = 'rounded',
    title = ' Preview ',
  })
  vim.wo[list_win].cursorline = true

  local function set_buffer_lines(bufnr, lines)
    vim.bo[bufnr].modifiable = true
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
    vim.bo[bufnr].modifiable = false
  end

  local function close()
    if closed then
      return
    end

    closed = true
    timer:stop()
    timer:close()

    if active_job then
      active_job:kill(15)
    end

    for _, win in ipairs({ input_win, list_win, preview_win }) do
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
    end
  end

  local function selected_hit()
    if #hits == 0 then
      return nil
    end

    return hits[vim.api.nvim_win_get_cursor(list_win)[1]]
  end

  local function highlight_selection()
    vim.api.nvim_buf_clear_namespace(list_buf, selection_ns, 0, -1)

    if #hits > 0 then
      local selected_line = vim.api.nvim_win_get_cursor(list_win)[1] - 1
      vim.api.nvim_buf_set_extmark(list_buf, selection_ns, selected_line, 0, {
        hl_group = 'Visual',
        hl_eol = true,
      })
    end
  end

  local function update_preview()
    local hit = selected_hit()
    if not hit then
      set_buffer_lines(preview_buf, { 'Type a query to search the Zvec index.' })
      return
    end

    local path = full_path(cwd, hit.path)
    if vim.fn.filereadable(path) == 0 then
      set_buffer_lines(preview_buf, { 'Cannot read ' .. path })
      return
    end

    local lines = vim.fn.readfile(path)
    local first_line = math.max(1, hit.start_line - 3)
    local last_line = math.min(#lines, hit.end_line + 3)
    set_buffer_lines(preview_buf, vim.list_slice(lines, first_line, last_line))
    vim.bo[preview_buf].filetype = vim.filetype.match({ filename = path }) or ''
  end

  local function render_results(status)
    if #hits == 0 then
      set_buffer_lines(list_buf, vim.split(status or 'No results', '\n', { plain = true }))
      update_preview()
      return
    end

    set_buffer_lines(list_buf, vim.tbl_map(function(hit)
      return ('%s:%d  %s'):format(hit.path, hit.start_line, hit.title)
    end, hits))
    vim.api.nvim_win_set_cursor(list_win, { 1, 0 })
    highlight_selection()
    update_preview()
  end

  local function open_selected()
    local hit = selected_hit()
    if not hit then
      return
    end

    local path = full_path(cwd, hit.path)
    close()
    vim.api.nvim_set_current_win(source_win)
    vim.cmd.edit(vim.fn.fnameescape(path))
    vim.api.nvim_win_set_cursor(source_win, { hit.start_line, 0 })
  end

  local function move_selection(offset)
    if #hits == 0 then
      return
    end

    local current_line = vim.api.nvim_win_get_cursor(list_win)[1]
    local next_line = math.min(math.max(current_line + offset, 1), #hits)
    vim.api.nvim_win_set_cursor(list_win, { next_line, 0 })
    highlight_selection()
    update_preview()
  end

  local function run_query(query)
    query_id = query_id + 1
    local current_query_id = query_id

    if active_job then
      active_job:kill(15)
      active_job = nil
    end

    if not query:match('%S') then
      hits = {}
      render_results('Type a query to search the Zvec index.')
      return
    end

    hits = {}
    render_results('Searching...')
    active_job = vim.system({
      'zg',
      'query',
      '--human',
      '--preview',
      'none',
      '--limit',
      '20',
      query,
    }, {
      cwd = cwd,
      text = true,
    }, function(result)
      vim.schedule(function()
        if closed or current_query_id ~= query_id then
          return
        end

        active_job = nil
        if result.code ~= 0 then
          render_results(result.stderr ~= '' and result.stderr or result.stdout)
          return
        end

        hits = parse_results(result.stdout)
        render_results()
      end)
    end)
  end

  local function schedule_query()
    timer:stop()
    timer:start(300, 0, vim.schedule_wrap(function()
      if closed then
        return
      end

      run_query(vim.api.nvim_buf_get_lines(input_buf, 0, 1, false)[1] or '')
    end))
  end

  vim.keymap.set('i', '<Esc>', close, { buffer = input_buf, desc = 'Close Zvec search' })
  vim.keymap.set('i', '<CR>', open_selected, { buffer = input_buf, desc = 'Open Zvec result' })
  vim.keymap.set({ 'i', 'n' }, '<Down>', function()
    move_selection(1)
  end, { buffer = input_buf, desc = 'Next Zvec result' })
  vim.keymap.set({ 'i', 'n' }, '<Up>', function()
    move_selection(-1)
  end, { buffer = input_buf, desc = 'Previous Zvec result' })
  vim.keymap.set('n', '<CR>', open_selected, { buffer = list_buf, desc = 'Open Zvec result' })
  vim.keymap.set('n', 'q', close, { buffer = list_buf, desc = 'Close Zvec search' })
  vim.keymap.set('n', '<Esc>', close, { buffer = list_buf, desc = 'Close Zvec search' })
  vim.keymap.set('n', '<Tab>', function()
    vim.api.nvim_set_current_win(input_win)
    vim.cmd('startinsert')
  end, { buffer = list_buf, desc = 'Focus Zvec query' })

  vim.api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI' }, {
    buffer = input_buf,
    callback = schedule_query,
  })
  vim.api.nvim_create_autocmd('CursorMoved', {
    buffer = list_buf,
    callback = update_preview,
  })

  render_results('Type a query to search the Zvec index.')
  vim.cmd('startinsert')
end

function M.search()
  if vim.fn.executable('zg') == 0 then
    vim.notify('zg is not installed', vim.log.levels.ERROR)
    return
  end

  open_picker(vim.fn.getcwd())
end

function M.rebuild_index()
  if vim.fn.executable('zg') == 0 then
    vim.notify('zg is not installed', vim.log.levels.ERROR)
    return
  end

  local cwd = vim.fn.getcwd()
  vim.notify('Rebuilding Zvec index...', vim.log.levels.INFO)
  vim.system({ 'zg', 'index', '--rebuild', '--hidden' }, {
    cwd = cwd,
    text = true,
  }, function(result)
    vim.schedule(function()
      if result.code == 0 then
        vim.notify('Zvec index rebuilt', vim.log.levels.INFO)
        return
      end

      vim.notify(result.stderr ~= '' and result.stderr or result.stdout, vim.log.levels.ERROR)
    end)
  end)
end

return M
