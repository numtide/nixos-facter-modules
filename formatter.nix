{ pkgs, inputs, ... }:
let
  hasNixFmt = pkgs.lib.meta.availableOn pkgs.stdenv.buildPlatform pkgs.nixfmt-rfc-style.compiler;
in
inputs.treefmt-nix.lib.mkWrapper pkgs {
  projectRootFile = ".git/config";

  programs = {
    nixfmt.enable = hasNixFmt;
    nixfmt.package = pkgs.nixfmt-rfc-style;

    deadnix.enable = true;
    prettier.enable = true;
    statix.enable = true;
  };

  settings = {
    global.excludes = [
      "LICENSE"
      "*.narHash"
      # unsupported extensions
      "*.{gif,png,svg,tape,mts,lock,mod,sum,toml,env,envrc,gitignore}"
    ];

    formatter = {
      deadnix = {
        priority = 1;
      };

      statix = {
        priority = 2;
      };

      nixfmt = pkgs.lib.mkIf hasNixFmt { priority = 3; };

      prettier = {
        options = [
          "--tab-width"
          "4"
        ];
        includes = [ "*.{css,html,js,json,jsx,md,mdx,scss,ts,yaml}" ];
      };
    };
  };
}
