vim.pack.add({
  'https://github.com/Maduki-tech/nvim-plantuml',
  'https://github.com/aklt/plantuml-syntax',
})

vim.filetype.add({
  extension = {
    iuml = 'plantuml',
    plantuml = 'plantuml',
    pu = 'plantuml',
    puml = 'plantuml',
    uml = 'plantuml',
  },
})

if vim.fn.executable('plantuml') == 1 then
  local function run_plantuml(bufnr, format, preview)
    local source = vim.api.nvim_buf_get_name(bufnr)
    if source == '' then
      vim.notify('Save the PlantUML file before rendering it', vim.log.levels.WARN)
      return
    end

    vim.system({ 'plantuml', '-t' .. format, source }, { text = true }, function(result)
      vim.schedule(function()
        if result.code ~= 0 then
          local message = result.stderr and result.stderr ~= ''
              and result.stderr
              or 'PlantUML rendering failed'
          vim.notify(message, vim.log.levels.ERROR)
          return
        end

        local output = vim.fn.fnamemodify(source, ':r') .. '.' .. format
        if preview then
          local _, error = vim.ui.open(output)
          if error then
            vim.notify(error, vim.log.levels.ERROR)
          end
        else
          vim.notify('Exported ' .. output)
        end
      end)
    end)
  end

  local function render_current(format, preview)
    local bufnr = vim.api.nvim_get_current_buf()
    if vim.bo[bufnr].modified then
      vim.cmd.write()
    end

    if preview then
      vim.b[bufnr].plantuml_auto_preview = true
    end

    run_plantuml(bufnr, format, preview)
  end

  local function preview()
    render_current('png', true)
  end

  vim.api.nvim_del_user_command('PlantUML')
  vim.api.nvim_create_user_command('PlantUML', function(opts)
    if opts.fargs[1] == 'preview' then
      preview()
      return
    end

    if opts.fargs[1] == 'export' and vim.tbl_contains({ 'png', 'svg' }, opts.fargs[2]) then
      render_current(opts.fargs[2], false)
      return
    end

    vim.notify('Usage: PlantUML preview | PlantUML export [png|svg]', vim.log.levels.WARN)
  end, {
    nargs = '+',
    complete = function(_, command_line)
      local args = vim.split(command_line, '%s+')
      if #args == 2 then
        return { 'preview', 'export' }
      elseif #args == 3 and args[2] == 'export' then
        return { 'png', 'svg' }
      end
      return {}
    end,
    desc = 'PlantUML commands',
  })

  vim.api.nvim_create_user_command('PlantUMLPreview', function()
    preview()
  end, {
    desc = 'Render and preview the current PlantUML file',
  })

  vim.api.nvim_create_autocmd('FileType', {
    group = vim.api.nvim_create_augroup('nm_plantuml', { clear = true }),
    pattern = 'plantuml',
    callback = function(args)
      local function map(lhs, rhs, desc)
        vim.keymap.set('n', lhs, rhs, {
          buffer = args.buf,
          desc = desc,
        })
      end

      map('<leader>lp', preview, 'PlantUML preview')
      map('<leader>lg', function()
        render_current('png', false)
      end, 'PlantUML export PNG')
      map('<leader>ls', function()
        render_current('svg', false)
      end, 'PlantUML export SVG')
    end,
  })

  vim.api.nvim_create_autocmd('BufWritePost', {
    group = 'nm_plantuml',
    pattern = { '*.iuml', '*.plantuml', '*.pu', '*.puml', '*.uml' },
    callback = function(args)
      if vim.b[args.buf].plantuml_auto_preview then
        run_plantuml(args.buf, 'png', true)
      end
    end,
  })
end
