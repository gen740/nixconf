vim.keymap.set('n', '<m-f>', function()
  vim.cmd('w')
  local handle = vim.system(
    { 'nix', 'run', 'nixpkgs#stylua', vim.fn.expand('%:p') },
    {},
    vim.schedule_wrap(function()
      local current_line = vim.fn.line('.')
      local win_view = vim.fn.winsaveview()
      vim.cmd('silent e!')
      vim.fn.winrestview(win_view) ---@diagnostic disable-line
      vim.fn.cursor(current_line, 0)
    end)
  )
  handle:wait()
end, { buffer = true })
