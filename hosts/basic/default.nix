{ flake, inputs, ... }:
{
  class = "nixos";
  value = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      ./config.nix
      flake.nixosModules.facter
      { config.facter.reportPath = ./report.json; }
    ];
  };
}
