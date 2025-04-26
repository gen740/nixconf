{ pkgs, ... }:
{
  home.packages = with pkgs; [
    skimpdf
    notion-app
    slack
    raycast
    zoom-us
    discord
    keycastr
    utm
    jetbrains.clion
  ];
}
