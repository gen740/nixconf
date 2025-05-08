vim.keymap.set('n', '<m-f>', function()
  vim.cmd('w')
  local handle = vim.system(
    { 'nix', 'run', 'nixpkgs#nixfmt-rfc-style', vim.fn.expand('%:p') },
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

vim.lsp.config('nixd', {
  cmd = { 'nix', 'run', 'nixpkgs#nixd' },
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
  filetypes = { 'nix' },
})
vim.opt_local.iskeyword:append('-')
