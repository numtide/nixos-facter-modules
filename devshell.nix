{
  pkgs,
  perSystem,
  ...
}:
perSystem.devshell.mkShell {
  env = [
    {
      name = "DEVSHELL_NO_MOTD";
      value = 1;
    }
  ];

  commands = [
    {package = perSystem.nixos-facter.default;}
    {package = pkgs.nix-unit;}
  ];
}
