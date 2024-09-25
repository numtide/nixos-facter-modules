{ lib, config, ... }:
let
  facterLib = import ../../lib/lib.nix lib;

  cfg = config.facter.detected.boot;
  inherit (config.facter) report;
in
{
  options.facter.detected.boot.enable = lib.mkEnableOption "Enable the Facter Boot module" // {
    default = true;
  };

  config =
    with lib;
    mkIf cfg.enable {
      boot.initrd.availableKernelModules = facterLib.stringSet (
        facterLib.collectDrivers (
          # Needed if we want to use the keyboard when things go wrong in the initrd.
          (report.hardware.usb_controller or [ ])
          # A disk might be attached.
          ++ (report.hardware.firewire_controller or [ ])
          # definitely important
          ++ (report.hardware.disk or [ ])
          ++ (report.hardware.storage_controller or [ ])
        )
      );
    };
}
