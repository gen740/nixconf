{
  description = "A flake package for the configuration of gen740";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      flake-parts,
      nixpkgs,
      home-manager,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];

      flake = {
        homeConfigurations = {
          gen-aarch64-darwin = home-manager.lib.homeManagerConfiguration {
            pkgs = import nixpkgs {
              system = "aarch64-darwin"; # 対象の system を明示
              config.allowUnfree = true;
            };
            modules = [
              ./home/gen/home.nix
              {
                home.username = "gen";
                home.homeDirectory = "/Users/gen";
              }
            ];
          };
          gen-aarch64-linux = home-manager.lib.homeManagerConfiguration {
            pkgs = import nixpkgs {
              system = "aarch64-linux"; # 対象の system を明示
              config.allowUnfree = true;
            };
            modules = [
              ./home/gen/home.nix
              {
                home.username = "gen";
                home.homeDirectory = "/home/gen";
              }
            ];
          };
          gen-x86_64-linux = home-manager.lib.homeManagerConfiguration {
            pkgs = import nixpkgs {
              system = "x86_64-linux"; # 対象の system を明示
              config.allowUnfree = true;
            };
            modules = [
              ./home/gen/home.nix
              {
                home.username = "gen";
                home.homeDirectory = "/home/gen";
              }
            ];
          };
        };
      };
    };
}
