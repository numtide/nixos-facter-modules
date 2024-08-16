{
  pname,
  pkgs,
  flake,
  inputs,
  ...
}:
pkgs.runCommandLocal pname { nativeBuildInputs = [ pkgs.nix-unit ]; } ''
  set -euo pipefail
  export HOME="$(realpath .)"
  for test in $(find ${flake} -type f -name "*.unit.nix"); do
    nix-unit --eval-store $HOME -I nixpkgs=${inputs.nixpkgs} $test
  done
  touch $out
''
