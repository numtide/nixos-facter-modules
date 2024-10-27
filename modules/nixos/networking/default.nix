{ config, lib, ... }:
{
  imports = [
    ./broadcom.nix
    ./intel.nix
  ];
  config.networking = lib.mkIf (builtins.length (config.facter.report.network_interface or [ ]) > 0) {
    useDHCP = lib.mkDefault true;
  };
}
