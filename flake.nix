{
  description = "Gen740's NixOS configuration";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs =
    {
      self,
      nix-darwin,
      home-manager,
      ...
    }:
    let
      nix-darwin-config =
        { pkgs, ... }:
        with pkgs;
        {
          environment.systemPackages = [
            coreutils
            curl
            wget
          ];
          fonts.packages = [ nerd-fonts.fira-code ];
          services.nix-daemon.enable = true;
          homebrew = {
            enable = true;
            casks = [
              "karabiner-elements"
              "minecraft"
              "xquartz"
              "discord"
              "skim"
              "iterm2"
              "wezterm"
            ];
            caskArgs.appdir = "/Applications/Homebrew Apps";
          };
          nix = {
            package = nix; # /run/current-system/sw/bin/nix
            settings = {
              experimental-features = "nix-command flakes";
              extra-platforms = "aarch64-darwin";
            };
            nixPath = lib.mkForce [
              {
                darwin-config = builtins.concatStringsSep ":" [
                  "$HOME/.nixpkgs/darwin-configuration.nix"
                  "$HOME/.nix-defexpr/channels"
                ];
              }
            ];
          };
          system.stateVersion = 4;
          nixpkgs.hostPlatform = "aarch64-darwin";
          nixpkgs.config.allowUnfree = true;
        };
      home-manager-config =
        let
          home = "/Users/gen";
          name = "gen";
        in
        { pkgs, ... }:
        {
          users.users.gen = {
            name = name;
            home = home;
          };
          home-manager.users.gen = (
            import ./home.nix {
              pkgs = pkgs;
              name = name;
              home = home;
            }
          );
        };
    in
    {
      darwinConfigurations.gen740 = nix-darwin.lib.darwinSystem {
        modules = [
          nix-darwin-config
          home-manager.darwinModules.home-manager
          home-manager-config
        ];
      };
      darwinPackages = self.darwinConfigurations.gen740.pkgs;
    };
}
