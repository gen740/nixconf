{ pkgs, ... }:

{
  enable = true;

  plugins = with pkgs.vimPlugins; [
    oil-nvim
    copilot-lua
    github-nvim-theme
    nvim-treesitter.withAllGrammars
  ];

  viAlias = true;
  withNodeJs = true;
  vimdiffAlias = true;
}
