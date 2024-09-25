{ lib, config, ... }:
let
  facterLib = import ../../lib/lib.nix lib;
  cfg = config.facter.detected.graphics;
in
{
  options.facter.detected = {
    graphics.enable = lib.mkEnableOption "Enable the Graphics module" // {
      default = builtins.length (config.facter.report.hardware.monitor or [ ]) > 0;
    };
    boot.graphics.kernelModules = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      # We currently don't auto import nouveau, in case the user might want to use the proprietary nvidia driver,
      # We might want to change this in future, if we have a better idea, how to handle this.
      default = lib.remove "nouveau" (
        facterLib.stringSet (facterLib.collectDrivers (config.facter.report.hardware.graphics_card or [ ]))
      );
      description = ''
        List of kernel modules to load at boot for the graphics card.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    hardware.graphics.enable = lib.mkDefault true;
    boot.initrd.kernelModules = config.facter.detected.boot.graphics.kernelModules;
  };
}
