{
  pkgs,
  ...
}:
{
  nixpkgs.config.allowUnfree = true;
  programs.zsh.enable = true;
  users.users.gen.shell = pkgs.zsh;
  system.autoUpgrade.enable = true;
}
