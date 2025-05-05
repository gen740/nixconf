{
  home-manager.users.gen =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        skimpdf
        notion-app
        raycast
        keycastr
        utm
        jetbrains.clion
        jetbrains.pycharm-professional
        jetbrains.dataspell
      ];
    };
}
