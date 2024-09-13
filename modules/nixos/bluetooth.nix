{ lib, config, ... }:
{
  options.facter.bluetooth.enable = lib.mkEnableOption "Enable the Facter bluetooth module" // {
    default = builtins.length (config.facter.report.hardware.bluetooth or []) > 0;
  };

  config.hardware.bluetooth.enable = lib.mkIf config.facter.bluetooth.enable (lib.mkDefault true);
}
