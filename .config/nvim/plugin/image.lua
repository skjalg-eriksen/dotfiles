vim.pack.add({
  'https://github.com/3rd/image.nvim',
})

local has_magick = vim.fn.executable('magick') == 1
local has_legacy_magick = vim.fn.executable('convert') == 1 and vim.fn.executable('identify') == 1

if has_magick or has_legacy_magick then
  require('image').setup({
    backend = 'kitty',
    processor = 'magick_cli',
  })
end
