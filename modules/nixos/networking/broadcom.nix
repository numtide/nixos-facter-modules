{ lib, config, ... }:
let
  inherit (config.facter) report;
  cfg = config.facter.networking.broadcom;
in
{
  options.facter.networking.broadcom = with lib; {
    full_mac.enable = mkEnableOption "Enable the Facter Broadcom Full MAC module" // {

      default = lib.any (
        { vendor, device, ... }:
        # vendor (0x14e4) Broadcom Inc. and subsidiaries
        (vendor.value or 0) == 5348
        && (lib.elem (device.value or 0) [
          17315 # 0x43a3
          17375 # 0x43df
          17388 # 0x43ec
          17363 # 0x43d3
          17369 # 0x43d9
          17385 # 0x43e9
          17338 # 0x43ba
          17339 # 0x43bb
          17340 # 0x43bc
          43602 # 0xaa52
          17354 # 0x43ca
          17355 # 0x43cb
          17356 # 0x43cc
          17347 # 0x43c3
          17348 # 0x43c4
          17349 # 0x43c5
        ])
      ) (report.hardware.network_controller or [ ]);

      defaultText = "hardware dependent";
    };
    sta.enable = mkEnableOption "Enable the Facter Broadcom STA module" // {

      default = lib.any (
        { vendor, device, ... }:
        # vendor (0x14e4) Broadcom Inc. and subsidiaries
        (vendor.value or 0) == 5348
        && (lib.elem (device.value or 0) [
          17169 # 0x4311
          17170 # 0x4312
          17171 # 0x4313
          17173 # 0x4315
          17191 # 0x4327
          17192 # 0x4328
          17193 # 0x4329
          17194 # 0x432a
          17195 # 0x432b
          17196 # 0x432c
          17197 # 0x432d
          17235 # 0x4353
          17239 # 0x4357
          17240 # 0x4358
          17241 # 0x4359
          17201 # 0x4331
          17312 # 0x43a0
          17329 # 0x43b1
        ])
      ) (report.hardware.network_controller or [ ]);

      defaultText = "hardware dependent";
    };
  };

  config = {
    hardware.enableRedistributableFirmware = lib.mkIf cfg.full_mac.enable (lib.mkDefault true);

    boot = lib.mkIf cfg.sta.enable {
      kernelModules = [ "wl" ];
      extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
    };
  };

}
