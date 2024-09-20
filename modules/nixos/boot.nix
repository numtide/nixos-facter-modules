{ lib, config, ... }:
let

  cfg = config.facter.boot;
  inherit (config.facter) report;
in
{
  options.facter.boot.enable = lib.mkEnableOption "Enable the Facter Boot module" // {
    default = true;
  };

  config =
    with lib;
    mkIf cfg.enable {
      boot.initrd.availableKernelModules = filter (dm: dm != null) (
        unique (
          map
            (
              {
                driver_module ? null,
                ...
              }:
              driver_module
            )
            (flatten [
              # Needed if we want to use the keyboard when things go wrong in the initrd.
              (report.hardware.usb_controller or [ ])
              # A disk might be attached.
              (report.hardware.firewire_controller or [ ])
              # definitely important
              (report.hardware.disk or [ ])
              (report.hardware.storage_controller or [ ])
            ])
        )
      );
    };
}
