return {
  -- rustup component add rust-analyzer
  settings = {
    ['rust-analyzer'] = {
      cargo = {
        allFeatures = true,
      },
      checkOnSave = true,
      check = {
        command = 'clippy',
      },
    },
  },
}
