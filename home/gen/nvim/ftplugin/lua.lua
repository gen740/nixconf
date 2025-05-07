vim.keymap.set('n', '<m-f>', function()
  vim.cmd('w')
  local handle = vim.system(
    { 'stylua', vim.fn.expand('%:p') },
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

local libraries = {
  '${3rd}/luv/library',
  '${3rd}/luassert/library',
}

do
  local path = vim.opt.packpath:get()[1] .. '/pack/myNeovimPackages/start'
  local handle = vim.loop.fs_scandir(path)
  while handle do
    local name, _ = vim.loop.fs_scandir_next(handle)
    if not name then
      break
    end
    table.insert(libraries, path .. '/' .. name)
  end
end

do
  local runtimes = vim.opt.runtimepath:get()
  for _, r in pairs(runtimes) do
    if vim.endswith(r, 'share/nvim/runtime') then
      table.insert(libraries, r)
    end
  end
end

vim.lsp.config('lua_ls', {
  cmd = { 'nix', 'run', 'nixpkgs#lua-language-server' },
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT',
      },
      diagnostics = {
        globals = { 'vim' },
      },
      workspace = {
        library = libraries,
        checkThirdParty = 'Disabled',
      },
      telemetry = {
        enable = false,
      },
      format = {
        enable = false,
      },
    },
  },
  filetypes = { 'lua' },
})
