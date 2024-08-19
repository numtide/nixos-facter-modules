{ inputs, ... }:
let
  facterLib = import ./lib.nix inputs.nixpkgs.lib;
in
facterLib // { tests = import ./lib.tests.nix facterLib; }
