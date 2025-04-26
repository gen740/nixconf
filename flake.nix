{
  description = "A flake package for the configuration of gen740";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    my-nvim-conf = {
      url = "github:gen740/my-nvim-conf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      flake-parts,
      nixpkgs,
      home-manager,
      nix-darwin,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];

      flake = {
        darwinConfigurations = {
          "gen740" = nix-darwin.lib.darwinSystem {
            system = "aarch64-darwin";
            modules = [
              {
                users.users.gen.home = "/Users/gen";
              }
              home-manager.darwinModules.home-manager
              ./home/gen/home.nix
              ./home/gen/macosApps.nix
              ./nix-darwin/configuration.nix
            ];
            specialArgs = { inherit inputs; };
          };
        };

        nixosConfigurations = {
          "nixos" = nixpkgs.lib.nixosSystem {
            system = "aarch64-linux";
            modules = [
              /etc/nixos/configuration.nix
              ./nixos/configuration.nix
              home-manager.nixosModules.home-manager
              ./home/gen/home.nix
            ];
          };

          "nixos-orbstack" = nixpkgs.lib.nixosSystem {
            system = "aarch64-linux";
            modules = [
              ./nixos/configuration.nix
              ./hardwares/orbstack/configuration.nix
              ./home/gen/home.nix
              home-manager.nixosModules.home-manager
            ];
          };
        };

      };

      perSystem =
        {
          pkgs,
          system,
          ...
        }:
        {
          apps = {
            switchOrbstackConfiguration = {
              type = "app";
              program =
                (pkgs.writeShellScriptBin "switch-orbstack-configuration" ''
                  exec sudo ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --flake .#nixos-orbstack
                '').outPath
                + "/bin/switch-orbstack-configuration";
            };

            switchDarwinConfiguration = {
              type = "app";
              program =
                (pkgs.writeShellScriptBin "switch-darwin-configuration" ''
                  exec sudo ${
                    inputs.nix-darwin.packages.${system}.darwin-rebuild
                  }/bin/darwin-rebuild switch --flake .#gen740
                '').outPath
                + "/bin/switch-darwin-configuration";
            };
          };
        };
    };
}
