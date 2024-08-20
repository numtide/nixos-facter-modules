{ inputs, ... }:
let
  inherit (inputs.nixpkgs) lib;
  facterLib = import ./lib.nix lib;
in
facterLib // { tests = import ./lib.tests.nix { inherit lib facterLib; }; }
