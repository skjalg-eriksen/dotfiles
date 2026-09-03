local M = {}
M.config = {
  labels = 'asdfghjklqwertyuiopzxcvbnm',
  auto_jump = true,
  mapping = 's',
}
function M.setup(options)
  M.config = vim.tbl_deep_extend('force', M.config, options or {})
  require('jumpmotion.render').setup_highlights()
end

function M.jump() require('jumpmotion.session').start(M.config) end

return M
