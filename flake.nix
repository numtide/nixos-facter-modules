{
  description = "NixOS Facter Modules";

  inputs = {
    blueprint.follows = "nixos-facter/blueprint";
    devshell.follows = "nixos-facter/devshell";
    nix-unit.follows = "nixos-facter/nix-unit";
    nixpkgs.follows = "nixos-facter/nixpkgs";
    nixos-facter.url = "github:numtide/nixos-facter";
    treefmt-nix.follows = "nixos-facter/treefmt-nix";
  };

  outputs = inputs:
    inputs.blueprint {
      inherit inputs;
      systems = [
        "aarch64-linux"
        "x86_64-linux"
      ];
    };
}
