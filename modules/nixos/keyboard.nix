{ lib, config, ... }:
let
  facterLib = import ../../lib/lib.nix lib;

  cfg = config.facter.detected.boot.keyboard;
  inherit (config.facter) report;
in
{
  options.facter.detected.boot.keyboard.enable =
    lib.mkEnableOption "Enable Keyboard support in the initrd"
    // {
      default = true;
    };

  config =
    lib.mkIf cfg.enable {
      boot.initrd.availableKernelModules = facterLib.stringSet (
        # Needed if we want to use the keyboard when things go wrong in the initrd.
        facterLib.collectDrivers (report.hardware.usb_controller or [ ])
      );
    };
}
