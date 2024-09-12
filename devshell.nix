{ pkgs, ... }:
pkgs.mkShellNoCC {
  packages = [
    pkgs.nix-unit
    (pkgs.writeScriptBin "update-dev-private-narHash" ''
      nix flake lock ./dev/private
      nix hash path ./dev/private | tr -d '\n' > ./dev/private.narHash
    '')
  ];
}
