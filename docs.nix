{
  pkgs,
  ...
}:
pkgs.mkShellNoCC {
  packages =
    let
      inherit (pkgs) lib;

      # Eval NixOS modules
      eval = lib.evalModules {
        modules = [
          # Load the root module
          ./modules/nixos/facter.nix
          {
            # Disable checks so it doesn't complain about NixOS related options which aren't available
            config._module.check = false;
            # Use the basic vm's report
            config.facter.reportPath = ./hosts/basic/report.json;
          }
        ];
      };

      # Capture root so we can identify our store paths below
      root = toString ./.;

      # Convert `/nix/store/...` store paths in the option declarations into a repository link.
      # NOTE: we point at the main branch, but for versioned docs this will be incorrect.
      # It's still a good starting point though.
      transformDeclaration =
        decl:
        let
          declStr = toString decl;
          subpath = lib.removePrefix "/" (lib.removePrefix root declStr);
        in
        assert lib.hasPrefix root declStr;
        {
          url = "https://github.com/numtide/nixos-facter-modules/blob/main/${subpath}";
          name = subpath;
        };

      # For each key in `options.facter` we generate it's own separate markdown file and then symlink join them together
      # into a common directory.
      optionsDoc = pkgs.symlinkJoin {
        name = "facter-module-docs";
        paths = lib.mapAttrsToList (
          name: value:
          let
            optionsDoc = pkgs.nixosOptionsDoc {
              options = value;
              transformOptions =
                opt:
                opt
                // {
                  declarations = map transformDeclaration opt.declarations;
                };
            };
          in
          pkgs.runCommand "${name}-doc" { } ''
            mkdir $out
            cat ${optionsDoc.optionsCommonMark} > $out/${name}.md
          ''
        ) eval.options.facter;
      };
    in
    with pkgs;
    [
      (pkgs.writeScriptBin "mkdocs" ''
        # rsync in NixOS modules doc to avoid issues with symlinks being owned by root
        rsync -aL ${optionsDoc}/ ./docs/content/reference/nixos_modules

        # execute the underlying command
        ${pkgs.mkdocs}/bin/mkdocs "$@"
      '')
    ]
    ++ (with pkgs.python3Packages; [
      mike
      mkdocs-material
    ]);
}
