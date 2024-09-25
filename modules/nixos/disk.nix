{ lib, config, ... }:
let
  facterLib = import ../../lib/lib.nix lib;

  cfg = config.facter.detected.boot.disk;
  inherit (config.facter) report;
in
{
  options.facter.detected.boot.disk.enable = lib.mkEnableOption "Enable Disk drivers in initrd" // {
    default = true;
  };

  config =
    lib.mkIf cfg.enable {
      boot.initrd.availableKernelModules = facterLib.stringSet (
        facterLib.collectDrivers (
          # A disk might be attached.
          (report.hardware.firewire_controller or [ ])
          # definitely important
          ++ (report.hardware.disk or [ ])
          ++ (report.hardware.storage_controller or [ ])
        )
      );
    };
}
