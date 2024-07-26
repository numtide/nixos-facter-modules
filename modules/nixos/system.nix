{
  config,
  options,
  lib,
  ...
}:
{
  nixpkgs = lib.mkIf (!options.nixpkgs.pkgs.isDefined) {
    hostPlatform = config.facter.system;
  };
}
