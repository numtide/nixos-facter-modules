{
  description = "NixOS Facter Modules";

  outputs =
    publicInputs:
    let
      loadPrivateFlake =
        path:
        let
          flakeHash = builtins.readFile "${toString path}.narHash";
          flakePath = "path:${toString path}?narHash=${flakeHash}";
        in
        builtins.getFlake (builtins.unsafeDiscardStringContext flakePath);

      privateFlake = loadPrivateFlake ./dev/private;

      privateInputs = privateFlake.inputs;

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
              pkgs = import privateInputs.nixpkgs { inherit system; };
              inherit system;
            };
          }) systems
        );
    in
    {
      lib = import ./lib { inherit (privateInputs.nixpkgs) lib; };

      nixosConfigurations = {
        basic =
          (import ./hosts/basic {
            inputs = privateInputs;
            flake = publicInputs.self;
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
        formatter = eachSystem (
          { pkgs, ... }: pkgs.callPackage ./formatter.nix { inputs = publicInputs // privateInputs; }
        );

        checks = eachSystem (
          { pkgs, ... }:
          {
            lib-tests = pkgs.runCommandLocal "lib-tests" { nativeBuildInputs = [ pkgs.nix-unit ]; } ''
              export HOME="$(realpath .)"
              export NIX_CONFIG='
              extra-experimental-features = nix-command flakes
              flake-registry = ""
              '

              nix-unit --expr '(import ${publicInputs.self}/lib { lib = import ${privateInputs.nixpkgs}/lib; }).tests'

              touch $out
            '';
          }
        );
      };
}
