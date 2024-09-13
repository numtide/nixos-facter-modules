{ lib, config, ... }:
{
  options.facter.graphics.enable = lib.mkEnableOption "Enable the Graphics module" // {
    default = builtins.length (config.facter.report.hardware.monitor or []) > 0;
  };

  config.hardware.graphics.enable = lib.mkIf config.facter.graphics.enable (lib.mkDefault true);
}
