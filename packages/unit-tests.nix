{
  pname,
  pkgs,
  flake,
  inputs,
  ...
}:
let
  inherit (pkgs) lib;
  overrideInputs =
    with lib;
    concatStringsSep " " (
      mapAttrsToList (n: v: "--override-input ${n} ${v}") (filterAttrs (n: _: n != "self") inputs)
    );
in
pkgs.runCommandLocal pname { nativeBuildInputs = [ pkgs.nix-unit ]; } ''
  set -euo pipefail
  export HOME="$(realpath .)"

  # nix-unit must be able to find all used inputs in the store, otherwise it will try to download them
  # this is why we provide the `--override-input` entries below

  nix-unit --eval-store "$HOME" \
    --extra-experimental-features flakes \
    ${overrideInputs} \
    --flake ${flake}#unit-tests

  touch $out
''
