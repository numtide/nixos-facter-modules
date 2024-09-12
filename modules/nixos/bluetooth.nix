{ lib, config, ... }:
let

  cfg = config.facter.boot;
  inherit (config.facter) report;
in
{
  options.facter.bluetooth.enable = lib.mkEnableOption "Enable the Facter bluetooth module" // {
    default =
      let
        bluetooth = report.hardware.bluetooth or [ ];
      in
      builtins.length bluetooth > 0;
  };

  config =
    with lib;
    mkIf cfg.enable {
      hardware.bluetooth.enable = lib.mkIf config.facter.bluetooth.enable (lib.mkDefault true);
    };
}
