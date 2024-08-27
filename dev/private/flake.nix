{
  description = "private inputs";
  # Follow the same nixpkgs as the main flake
  inputs.nixpkgs-dev.url = "github:NixOS/nixpkgs/nixos-unstable";

  inputs.treefmt-nix.url = "github:numtide/treefmt-nix";
  inputs.treefmt-nix.inputs.nixpkgs.follows = "";

  outputs = _: { };
}
