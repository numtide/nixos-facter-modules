{ lib, config, ... }:
let
  inherit (config.facter) report;

in
{
  options.facter.swap.enable = lib.mkEnableOption "Enable the Facter Swap module" // {
    default = lib.length (report.swap or [ ]) > 0;
    defaultText = "enabled if there are swap entries in the report";
  };

  # generate the swapDevices option from the swap devices that were active when the report was captured
  config = lib.mkIf config.facter.swap.enable {
    swapDevices =
      let
        # we only take swap partitions that are not zram devices
        # https://github.com/NixOS/nixpkgs/blob/dac9cdf8c930c0af98a63cbfe8005546ba0125fb/nixos/modules/installer/tools/nixos-generate-config.pl#L335-L357
        swapPartitions = lib.filter (
          { filename, type, ... }: type == "partition" && !(lib.hasPrefix "/dev/zram" filename)
        ) report.swap;
      in
      map (
        { filename, ... }:
        {
          device = filename;
        }
      ) swapPartitions;
  };

}
