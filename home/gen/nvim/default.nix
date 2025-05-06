{ pkgs, ... }:
{
  enable = true;
  plugins =
    (with pkgs.vimPlugins; [
      oil-nvim
      copilot-lua
      nvim-treesitter
      github-nvim-theme
    ])
    ++ (with pkgs.vimPlugins.nvim-treesitter-parsers; [
      asm
      c
      cpp
      diff
      git_config
      git_rebase
      gitcommit
      gitignore
      go
      javascript
      json
      latex
      lua
      nix
      python
      rust
      toml
      typescript
      vhdl
      vim
      vimdoc
      yaml
      doxygen
      typst
    ]);
  viAlias = true;
  withNodeJs = true;
  vimdiffAlias = true;
}
