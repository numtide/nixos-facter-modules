{
  description = "NixOS Facter Modules";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs =
    publicInputs@{
      self,
      nixpkgs,
      ...
    }:
    let
      inherit (publicInputs.nixpkgs) lib;

      loadPrivateFlake =
        path:
        let
          flakeHash = nixpkgs.lib.fileContents "${toString path}.narHash";
          flakePath = "path:${toString path}?narHash=${flakeHash}";
        in
        builtins.getFlake (builtins.unsafeDiscardStringContext flakePath);

      privateFlake = loadPrivateFlake ./dev/private;

      privateInputs = privateFlake.inputs;

      inputs = publicInputs;

      systems = [
        "aarch64-linux"
        "riscv64-linux"
        "x86_64-linux"
      ];
      eachSystem =
        f:
        builtins.listToAttrs (
          builtins.map (system: {
            name = system;
            value = f {
              pkgs = import nixpkgs { inherit system; };
              inherit system;
            };
          }) systems
        );
    in
    {
      lib = import ./lib { inherit inputs; };

      nixosConfigurations = {
        basic =
          (import ./hosts/basic {
            inherit inputs;
            flake = inputs.self;
          }).value;
      };
      nixosModules = {
        boot = ./modules/nixos/boot.nix;
        facter = ./modules/nixos/facter.nix;
        firmware = ./modules/nixos/firmware.nix;
        networking = ./modules/nixos/networking;
        system = ./modules/nixos/system.nix;
        virtualisation = ./modules/nixos/virtualisation.nix;
      };
    }
    //
      # DevOutputs
      {
        devShells = eachSystem (
          { pkgs, ... }:
          {
            default = pkgs.callPackage ./devshell.nix { };
          }
        );
        formatter = eachSystem ({ pkgs, ... }: pkgs.callPackage ./formatter.nix { inputs = inputs // privateInputs; });

        checks = eachSystem (
          { pkgs, ... }:
          {
            lib-tests = pkgs.runCommandLocal "lib-tests" { nativeBuildInputs = [ pkgs.nix-unit ]; } ''
              export HOME="$(realpath .)"
              export NIX_CONFIG='
              extra-experimental-features = nix-command flakes
              flake-registry = ""
              '

              nix-unit --flake ${inputs.self}#lib.tests ${
                toString (
                  lib.mapAttrsToList (k: v: "--override-input ${k} ${v}") (builtins.removeAttrs inputs [ "self" ])
                )
              }

              touch $out
            '';
          }
        );
      };
}
