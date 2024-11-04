{ config, lib, ... }:
{
  imports = [
    ./broadcom.nix
    ./intel.nix
  ];
  config = lib.mkIf (builtins.length (config.facter.report.network_interface or [ ]) > 0) {
    networking.useDHCP = lib.mkDefault true;
    networking.useNetworkd = lib.mkDefault true;
  };
}
