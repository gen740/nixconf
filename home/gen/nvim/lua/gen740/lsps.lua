local on_attach = function(client, bufnr)
  local chars = {}
  for i = 32, 126 do
    table.insert(chars, string.char(i))
  end
  client.server_capabilities.completionProvider.triggerCharacters = chars
  vim.lsp.completion.enable(true, client.id, bufnr, {
    autotrigger = true,
    convert = function(item)
      return { abbr = item.label:gsub('%b()', '') }
    end,
  })
end

vim.lsp.enable { 'clangd', 'lua_ls', 'pyright', 'ruff', 'json', 'nixd', 'yamlls' }

vim.lsp.config('*', {
  on_attach = on_attach,
})

vim.lsp.config('clangd', {
  cmd = {
    'clangd',
    '--clang-tidy',
    '--background-index',
    '--offset-encoding=utf-8',
  },
  root_markers = { '.clangd', 'compile_commands.json' },
  filetypes = { 'c', 'cpp' },
  on_attach = on_attach,
})

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
  on_attach = on_attach,
})

vim.lsp.config('json', {
  settings = {
    json = {
      schemas = {
        {
          fileMatch = { 'package.json' },
          url = 'https://json.schemastore.org/package.json',
        },
        {
          fileMatch = { 'tsconfig*.json' },
          url = 'https://json.schemastore.org/tsconfig.json',
        },
        {
          fileMatch = { '.luarc.json' },
          url = 'https://raw.githubusercontent.com/sumneko/vscode-lua/master/setting/schema.json',
        },
        {
          fileMatch = { 'pyrightconfig.json' },
          url = 'https://raw.githubusercontent.com/microsoft/pyright/main/packages/vscode-pyright/schemas/pyrightconfig.schema.json',
        },
        {
          fileMatch = { 'biome.json' },
          url = 'https://biomejs.dev/schemas/1.6.1/schema.json',
        },
        {
          fileMatch = { 'appsscript.json' },
          url = 'https://raw.githubusercontent.com/SchemaStore/schemastore/master/src/schemas/json/appsscript.json',
        },
        {
          fileMatch = { 'deno.json' },
          url = 'https://raw.githubusercontent.com/denoland/deno/v1.41.0/cli/schemas/config-file.v1.json',
        },
      },
    },
  },
  on_attach = on_attach,
})

vim.lsp.config('nixd', {
  settings = {
    nixd = {
      nixpkgs = {
        expr = 'let flake = builtins.getFlake ("git+file://" + toString ./); in flake.inputs.nixpkgs.legacyPackages.${builtins.currentSystem}',
      },
      formatting = {
        command = { 'nixfmt' },
      },
      options = {
        nixos = {
          expr = '(builtins.getFlake ("git+file://" + toString ./.)).nixosConfigurations.k-on.options',
        },
        home_manager = {
          expr = '(builtins.getFlake ("git+file://" + toString ./.)).homeConfigurations."ruixi@k-on".options',
        },
      },
    },
  },
  on_attach = on_attach,
})

vim.lsp.config('yamlls', {
  settings = {
    yaml = {
      schemas = {
        ['https://json.schemastore.org/github-workflow.json'] = '/.github/workflows/*',
        ['https://json.schemastore.org/clang-format.json'] = '.clang-format',
        ['https://gitlab.com/gitlab-org/gitlab/-/raw/master/app/assets/javascripts/editor/schema/ci.json'] = '.gitlab-ci.y*ml',
        ['https://taskfile.dev/schema.json'] = 'Taskfile.yaml',
        ['https://json.schemastore.org/clangd.json'] = '.clangd',
        ['https://raw.githubusercontent.com/common-workflow-lab/cwl-ts-auto/main/json_schemas/cwl_schema.json'] = '*.cwl',
      },
    },
  },
  on_attach = on_attach,
})
