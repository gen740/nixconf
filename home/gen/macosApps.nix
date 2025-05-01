{
  home-manager.users.gen =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        skimpdf
        notion-app
        raycast
        discord
        keycastr
        utm
        jetbrains.clion
      ];
    };
}
