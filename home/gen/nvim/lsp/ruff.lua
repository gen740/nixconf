return {
  cmd = {
    'nix',
    'shell',
    'nixpkgs#ruff',
    '-c',
    'ruff',
    'server',
  },
  filetypes = { 'python' },
}
