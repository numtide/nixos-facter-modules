{ lib, config, ... }:
let
  cfg = config.facter.detected.graphics.amd;
in
{
  options.facter.detected.graphics = {
    amd.enable = lib.mkEnableOption "Enable the AMD Graphics module" // {
      default =
        let
          graphicsDrivers = builtins.map (graphics_card: graphics_card.driver) (
            config.facter.report.hardware.graphics_card or [ ]
          );
        in
        builtins.elem "amdgpu" graphicsDrivers;
    };
  };
  config = lib.mkIf cfg.enable {
    services.xserver.videoDrivers = [ "amdgpu" ];
  };
}
