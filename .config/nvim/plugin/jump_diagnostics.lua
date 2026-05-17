-- if true then return end

-- jump diagnostics by severity
local diagnostic_goto = function(next, severity)
  return function()
    vim.diagnostic.jump({
      count = next and 1 or -1,
      severity = severity,
      float = true,
    })
  end
end

vim.keymap.set('n', ']e', diagnostic_goto(true, vim.diagnostic.severity.ERROR), {
  desc = 'Next diagnostic error',
})

vim.keymap.set('n', '[e', diagnostic_goto(false, vim.diagnostic.severity.ERROR), {
  desc = 'Previous diagnostic error',
})

vim.keymap.set('n', ']w', diagnostic_goto(true, vim.diagnostic.severity.WARN), {
  desc = 'Next diagnostic warning',
})

vim.keymap.set('n', '[w', diagnostic_goto(false, vim.diagnostic.severity.WARN), {
  desc = 'Previous diagnostic warning',
})
