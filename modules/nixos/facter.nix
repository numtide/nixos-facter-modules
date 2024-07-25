{ lib, config, ... }:
{
  imports = [
    ./boot.nix
    ./networking
    ./virtualisation.nix
  ];

  options.facter = with lib; {
    reportPath = mkOption { type = types.path; };
    report = mkOption {
      type = types.raw;
      default = builtins.fromJSON (builtins.readFile config.facter.reportPath);
    };
  };
}
