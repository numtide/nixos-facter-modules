{
  config,
  options,
  lib,
  ...
}:
{
  nixpkgs = lib.mkIf (!options.nixpkgs.pkgs.isDefined) {
    hostPlatform = lib.mkDefault config.facter.report.system;
  };
}
