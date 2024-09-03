{ lib }:
let
  facterLib = import ./lib.nix lib;
in
facterLib // { tests = import ./lib.tests.nix facterLib; }
