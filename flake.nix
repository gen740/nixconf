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

      perSystem =
        { pkgs, ... }:
        {
          # 開発環境の設定などをここに書けます
        };

      flake = {
        homeConfigurations = {
          gen = home-manager.lib.homeManagerConfiguration {
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
        };
      };
    };
}
