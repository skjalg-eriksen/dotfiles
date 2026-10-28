local function schema_url(bufnr)
  for _, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, 20, false)) do
    local url = line:match('^%s*#%s*yaml%-language%-server:%s*%$schema=(%S+)')
    if url then
      return url
    end
  end
end

local function root_dir(bufnr, on_dir)
  local url = schema_url(bufnr)
  if not url or not url:match('^https?://') then
    on_dir(vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr)))
    return
  end

  vim.ui.select({ 'Allow', 'Reject' }, {
    prompt = ('Allow yaml-language-server to download this schema?\n%s'):format(url),
  }, function(choice)
    if choice == 'Allow' then
      on_dir(vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr)))
    end
  end)
end

local mason_server = vim.fs.joinpath(vim.fn.stdpath('data'), 'mason', 'bin', 'yaml-language-server')

return {
  cmd = vim.fn.executable(mason_server) == 1
      and { mason_server, '--stdio' }
    or { 'yaml-language-server', '--stdio' },
  root_dir = root_dir,
  reuse_client = function()
    return false
  end,
  settings = {
    yaml = {
      schemaStore = {
        enable = false,
      },
    },
  },
}
