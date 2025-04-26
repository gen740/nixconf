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
    nvim-conf = {
      url = "github:gen740/config.nvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      flake-parts,
      nixpkgs,
      home-manager,
      nix-darwin,
      nvim-conf,
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
          "gen740noMacBook-Pro" = nix-darwin.lib.darwinSystem {
            system = "aarch64-darwin";
            modules = [
              {
                nixpkgs.config.allowUnfree = true;
              }
              ./nix-darwin/configuration.nix
              home-manager.darwinModules.home-manager
              {
                users.users.gen.home = "/Users/gen";
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  users.gen = ./home/gen/home.nix;
                };
              }
              {
                home-manager.users.gen = ./home/macos_common.nix;
              }
              {
                home-manager.users.gen.home.file.".config/nvim".source = nvim-conf;
              }
            ];
            specialArgs = { inherit inputs; };
          };
        };

        nixosConfigurations = {
          "nixos" = nixpkgs.lib.nixosSystem {
            system = "aarch64-linux";
            modules = [
              {
                nixpkgs.config.allowUnfree = true;
              }
              /etc/nixos/configuration.nix
              ./nixos/configuration.nix
              home-manager.nixosModules.home-manager
              {
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  users.gen = ./home/gen/home.nix;
                };
              }
              {
                home-manager.users.gen.home.file.".config/nvim".source = nvim-conf;
              }
            ];
          };

          "nixos-orbstack" = nixpkgs.lib.nixosSystem {
            system = "aarch64-linux";
            modules = [
              ./nixos/configuration.nix
              ./hardwares/orbstack/configuration.nix
              {
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  users.gen = ./home/gen/home.nix;
                };
              }
              home-manager.nixosModules.home-manager
              {
                home-manager.users.gen.home.file.".config/nvim".source = nvim-conf;
              }
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
                  }/bin/darwin-rebuild switch --flake .#gen740noMacBook-Pro
                '').outPath
                + "/bin/switch-darwin-configuration";
            };
          };
        };
    };
}
