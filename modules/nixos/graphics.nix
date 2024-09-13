{ lib, config, ... }:
{
  options.facter.graphics.enable = lib.mkEnableOption "Enable the Graphics module" // {
    # In future we might want to enable graphics on virtual machines, but just now there its a bit unclear
    # for which graphics cards we should enable it
    default = builtins.length (config.facter.report.hardware.monitor or [ ]) > 0 && config.facter.virtualisation.none.enable;
  };
  config.hardware.graphics.enable = lib.mkIf config.facter.graphics.enable (lib.mkDefault true);
}
