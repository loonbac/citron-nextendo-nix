{
  description = "Citron Nextendo for Nix and NixOS";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
          generic = pkgs.callPackage ./nix/package.nix { };
        in
        {
          default = generic;
          citron-nextendo = generic;
        }
        // nixpkgs.lib.optionalAttrs (system == "x86_64-linux") {
          citron-nextendo-v3 = pkgs.callPackage ./nix/package.nix {
            x86_64Variant = "v3";
          };
        }
      );

      apps = forAllSystems (
        system:
        let
          package = self.packages.${system}.default;
          mkApp = pkg: {
            type = "app";
            program = nixpkgs.lib.getExe pkg;
            meta = pkg.meta;
          };
        in
        {
          default = mkApp package;
          citron-nextendo = mkApp package;
        }
        // nixpkgs.lib.optionalAttrs (system == "x86_64-linux") {
          citron-nextendo-v3 = mkApp self.packages.${system}.citron-nextendo-v3;
        }
      );

      overlays.default = final: _prev: {
        citron-nextendo = final.callPackage ./nix/package.nix { };
      }
      // final.lib.optionalAttrs final.stdenv.hostPlatform.isx86_64 {
        citron-nextendo-v3 = final.callPackage ./nix/package.nix {
          x86_64Variant = "v3";
        };
      };

      nixosModules = {
        default = import ./nix/module.nix { inherit self; };
        citron-nextendo = self.nixosModules.default;
      };
    };
}
