return {
  -- brew install lua-language-server
  -- pacman -S lua-language-server
  settings = {
    Lua = {
      diagnostics = {
        globals = { 'vim' },
      },
    },
    workspace = {
      library = vim.api.nvim_get_runtime_file('', true),
    },
  },
}
