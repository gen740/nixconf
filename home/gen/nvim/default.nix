{ pkgs, ... }:

{
  enable = true;

  plugins = with pkgs.vimPlugins; [
    oil-nvim
    copilot-lua
    github-nvim-theme
  ];

  viAlias = true;
  withNodeJs = true;
  vimdiffAlias = true;
}
