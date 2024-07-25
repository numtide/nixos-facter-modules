{
  lib,
  config,
  ...
}: let
  facterLib = import ../../lib/lib.nix lib;

  inherit (config.facter) report;
  isBaremetal = config.facter.virtualisation.none.enable;
  hasAmdCpu = facterLib.hasAmdCpu report;
  hasIntelCpu = facterLib.hasIntelCpu report;
in {
  imports = [ ./virtualisation.nix ];
  config = {
    # none (e.g. bare-metal)
    # provide firmware for devices that might not have been detected by nixos-facter
    hardware.enableRedistributableFirmware = lib.mkDefault isBaremetal;

    # update microcode
    hardware.cpu.amd.updateMicrocode = lib.mkIf (isBaremetal && hasAmdCpu)
      (lib.mkDefault config.hardware.enableRedstributableFirmware);
    hardware.cpu.intel.updateMicrocode = lib.mkIf (isBaremetal && hasIntelCpu)
      (lib.mkDefault config.hardware.enableRedistributableFirmware);
  };
}
