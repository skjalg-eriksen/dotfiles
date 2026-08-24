return {
  -- Install clangd through your system package manager (for example: pacman -S clang).
  -- A compile_commands.json file lets clangd resolve project-specific include paths.
  filetypes = {
    'c',
    'cpp',
    'objc',
    'objcpp',
    'cuda',
    'proto',
    'h',
    'hh',
    'hpp',
    'hxx',
  },
  root_markers = {
    'compile_commands.json',
    'compile_flags.txt',
    '.clangd',
    '.git',
  },
}
