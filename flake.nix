{
  description = "NixOS Facter Modules";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";
    blueprint = {
      url = "github:numtide/blueprint";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    inputs.blueprint {
      inherit inputs;
      systems = [
        "aarch64-linux"
        "riscv64-linux"
        "x86_64-linux"
      ];
    }
    // (
      let
        inherit (inputs.nixpkgs) lib;

        findTests =
          path:
          with lib;
          filterAttrsRecursive (_n: v: v != { }) (
            mapAttrs' (
              n: v:
              if (v == "regular" && (hasSuffix ".unit.nix" n)) then
                nameValuePair n (import "${path}/${n}" lib)
              else if v == "directory" then
                nameValuePair n (findTests "${path}/${n}")
              else
                nameValuePair n { }
            ) (builtins.readDir path)
          );
      in
      {
        # you can run all the tests from a devshell with `nix-unit --flake .#unit-tests` or `nix build .#unit-tests`
        unit-tests = findTests ./.;
      }
    );
}
