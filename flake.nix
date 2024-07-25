{
  description = "NixOS Facter Modules";

  inputs = {
    blueprint.follows = "nixos-facter/blueprint";
    devshell.follows = "nixos-facter/devshell";
    nixpkgs.follows = "nixos-facter/nixpkgs";
    nixos-facter.url = "github:numtide/nixos-facter";
    treefmt-nix.follows = "nixos-facter/treefmt-nix";
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
    };
}
