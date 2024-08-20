{ lib, config, ... }:
let
  facterLib = import ../../lib/lib.nix lib;
  report = facterLib.checkReportVersion { max = 1; } config.facter.report;

  isBaremetal = config.facter.virtualisation.none.enable;
  hasAmdCpu = facterLib.hasAmdCpu report;
  hasIntelCpu = facterLib.hasIntelCpu report;
in
{
  imports = [ ./virtualisation.nix ];
  config = lib.mkIf isBaremetal {
    # none (e.g. bare-metal)
    # provide firmware for devices that might not have been detected by nixos-facter
    hardware.enableRedistributableFirmware = lib.mkDefault true;

    # update microcode
    hardware.cpu.amd.updateMicrocode = lib.mkIf hasAmdCpu (
      lib.mkDefault config.hardware.enableRedstributableFirmware
    );
    hardware.cpu.intel.updateMicrocode = lib.mkIf hasIntelCpu (
      lib.mkDefault config.hardware.enableRedistributableFirmware
    );
  };
}
