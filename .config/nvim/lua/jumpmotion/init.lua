local M = {}
M.config = {
  labels = 'asdfghjklqwertyuiopzxcvbnm',
  auto_jump = true,
  mapping = 's',
  -- nil follows Neovim's 'ignorecase' + 'smartcase' options. Set true to
  -- always use smart-case or false for strictly case-sensitive matching.
  smartcase = nil,
  -- These use no background by default, which is calmer than IncSearch while
  -- still keeping targets and labels distinct. Colors may be hex values or
  -- named colors supported by :highlight; omit bg for terminal transparency.
  highlights = {
    JumpMotionMatch = { underline = true },
    JumpMotionLabel = { bold = true, underline = true },
    JumpMotionDim = { link = 'Comment' },
  },
}
function M.setup(options)
  M.config = vim.tbl_deep_extend('force', M.config, options or {})
  require('jumpmotion.render').setup_highlights(M.config.highlights)
end

function M.jump() require('jumpmotion.session').start(M.config) end

return M
