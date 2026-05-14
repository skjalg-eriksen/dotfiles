-- if true then return end

vim.pack.add({
  'https://github.com/nvim-treesitter/nvim-treesitter',
})

require('nvim-treesitter').setup()

local parsers = {
  'lua',
  'vim',
  'vimdoc',
  'python',
  'markdown',
  'markdown_inline',
  'bash',
  'json',
  'yaml',
  'toml',
}

require('nvim-treesitter').install(parsers)

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('nm_treesitter', { clear = true }),
  callback = function(args)
    local lang = vim.treesitter.language.get_lang(args.match)
    if not lang then
      return
    end

    local ok = pcall(vim.treesitter.start, args.buf, lang)
    if not ok then
      return
    end

    vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})
