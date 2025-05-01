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
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
    };
  };

  outputs =
    inputs@{
      self,
      flake-parts,
      nixpkgs,
      home-manager,
      nix-darwin,
      nixos-hardware,
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
              ./hardwares/darwin/configuration.nix
              {
                home-manager.users.gen.home.shellAliases = {
                  switch-conf = ''
                    nix flake metadata --refresh "github:gen740/my-nix-conf?ref=main" && \
                    nix run -v -L --show-trace "github:gen740/my-nix-conf?ref=main#switchDarwinConfiguration"
                  '';
                };
              }
            ];
            specialArgs = { inherit inputs; };
          };
        };

        nixosConfigurations = {
          "nixos-t2mac" = nixpkgs.lib.nixosSystem {
            system = "aarch64-linux";
            modules = [
              nixos-hardware.nixosModules.apple-t2

              ./hardwares/T2mac/configuration.nix
              ./nixos/configuration.nix
              home-manager.nixosModules.home-manager
              ./home/gen/home.nix
              {
                home-manager.users.gen.home.shellAliases = {
                  switch-conf = ''
                    nix flake metadata --refresh "github:gen740/my-nix-conf?ref=main" && \
                    nix run -v -L --show-trace "github:gen740/my-nix-conf?ref=main#switchT2MacConfiguration"
                  '';
                };
              }
            ];
            specialArgs = { inherit inputs; };
          };

          "nixos-orbstack" = nixpkgs.lib.nixosSystem {
            system = "aarch64-linux";
            modules = [
              ./nixos/configuration.nix
              ./hardwares/orbstack/configuration.nix
              ./home/gen/home.nix
              home-manager.nixosModules.home-manager
              {
                home-manager.users.gen.home.shellAliases = {
                  switch-conf = ''
                    nix flake metadata --refresh "github:gen740/my-nix-conf?ref=main" && \
                    nix run -v -L --show-trace "github:gen740/my-nix-conf?ref=main#switchOrbstackConfiguration"
                  '';
                };
              }
            ];
            specialArgs = { inherit inputs; };
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
                  exec sudo ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch -v -L --show-trace --flake ${self.outPath}#nixos-orbstack
                '').outPath
                + "/bin/switch-orbstack-configuration";
            };

            switchT2MacConfiguration = {
              type = "app";
              program =
                (pkgs.writeShellScriptBin "switch-t2mac-configuration" ''
                  exec sudo ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch -v -L --show-trace --flake ${self.outPath}#nixos-t2mac
                '').outPath
                + "/bin/switch-t2mac-configuration";
            };

            switchDarwinConfiguration = {
              type = "app";
              program =
                (pkgs.writeShellScriptBin "switch-darwin-configuration" ''
                  exec ${
                    inputs.nix-darwin.packages.${system}.darwin-rebuild
                  }/bin/darwin-rebuild switch -v -L --show-trace --flake ${self.outPath}#gen740
                '').outPath
                + "/bin/switch-darwin-configuration";
            };
          };
        };
    };
}
