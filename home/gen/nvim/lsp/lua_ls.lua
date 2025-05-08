local libraries = {
  '${3rd}/luv/library',
  '${3rd}/luassert/library',
  vim.env.VIMRUNTIME,
}

do
  local path = vim.opt.packpath:get()[1] .. '/pack/myNeovimPackages/start'
  local handle = vim.loop.fs_scandir(path)
  while handle do
    local name = vim.loop.fs_scandir_next(handle)
    if not name then
      break
    end
    local lua_dir = path .. '/' .. name .. '/lua'
    local stat = vim.loop.fs_stat(lua_dir)
    if stat and stat.type == 'directory' then
      table.insert(libraries, path .. '/' .. name)
    end
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
