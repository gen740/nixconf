return {
  cmd = {
    'nix',
    'shell',
    'nixpkgs#pyright',
    '-c',
    'pyright-langserver',
  },
  filetypes = { 'python' },
}
