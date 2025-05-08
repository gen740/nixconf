local libraries = {
  '${3rd}/luv/library',
  '${3rd}/luassert/library',
  vim.env.VIMRUNTIME,
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

return {
  cmd = { 'nix', 'run', 'nixpkgs#lua-language-server' },
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT',
      },
      workspace = {
        library = libraries,
        checkThirdParty = 'Disabled',
      },
      telemetry = {
        enable = false,
      },
    },
  },
  filetypes = { 'lua' },
}
