{lib, config,...}:
let
  cfg = config.facter.detected.graphics.amd;
in
{
  options.facter.detected.graphics = {
    amd.enable = lib.mkEnableOption "Enable the AMD Graphics module" // {
      default = builtins.elem "amdgpu" (builtins.map (graphics_card: graphics_card.driver) config.facter.report.hardware.graphics_card);
    };
  };
  config = lib.mkIf cfg.enable {
  services.xserver.videoDrivers = ["amdgpu"];
  };
}
