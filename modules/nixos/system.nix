{
  config,
  options,
  lib,
  ...
}:
{
  nixpkgs = lib.mkIf (!options.nixpkgs.pkgs.isDefined) {
    hostPlatform = lib.mkIf (config.facter.report.system or null != null) (
      lib.mkDefault config.facter.report.system
    );
  };
}
