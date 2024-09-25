{ lib, config, ... }:
let
  facterLib = import ../../lib/lib.nix lib;
in
{
  options.facter.graphics.enable = lib.mkEnableOption "Enable the Graphics module" // {
    default = builtins.length (config.facter.report.hardware.monitor or [ ]) > 0;
  };

  config = lib.mkIf config.facter.graphics.enable {
    hardware.graphics.enable = lib.mkDefault true;
    boot.initrd.kernelModules = facterLib.stringSet (
      facterLib.collectDrivers (config.facter.report.hardware.graphics_card or [ ])
    );
  };
}
