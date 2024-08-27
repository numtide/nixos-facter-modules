{
  description = "NixOS Facter Modules";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs: let
    inherit (inputs.nixpkgs) lib;

    findTests = path:
      with lib;
        filterAttrsRecursive (_n: v: v != {}) (
          mapAttrs' (
            n: v:
              if (v == "regular" && (hasSuffix ".unit.nix" n))
              then nameValuePair n (import "${path}/${n}" lib)
              else if v == "directory"
              then nameValuePair n (findTests "${path}/${n}")
              else nameValuePair n {}
          ) (builtins.readDir path)
        );
  in {
    lib = import ./lib { inherit inputs; };

    nixosConfigurations = {
      basic = (import ./hosts/basic { inherit inputs; flake = inputs.self; }).value;
    };
    nixosModules = {
      boot = ./modules/nixos/boot.nix;
      facter = ./modules/nixos/facter.nix;
      firmware = ./modules/nixos/firmware.nix;
      networking = ./modules/nixos/networking;
      system = ./modules/nixos/system.nix;
      virtualisation = ./modules/nixos/virtualisation.nix;
    };
    unit-tests = findTests ./.;
  };
}
