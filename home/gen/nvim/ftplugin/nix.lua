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
