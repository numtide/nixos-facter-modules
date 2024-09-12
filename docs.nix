{
  pkgs,
  ...
}:
pkgs.mkShellNoCC {
  packages =
    let
      inherit (pkgs) lib;

      # Capture root so we can identify our store paths below
      root = toString ./.;

      snakeCase = with lib; replaceStrings upperChars (map (s: "_" + s) lowerChars);

      # Eval Facter module
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

      # Convert options into options doc, transforming declaration paths to point to the github repository.
      nixosOptionsDoc =
        _name: options:
        pkgs.nixosOptionsDoc {
          inherit options;
          transformOptions =
            opt:
            opt
            // {
              declarations = map transformDeclaration opt.declarations;
            };
        };

      # Take an options attr set and produce a markdown file.
      mkMarkdown =
        name: options:
        let
          optionsDoc = nixosOptionsDoc name options;
        in
        pkgs.runCommand "${name}-markdown" { } ''
          mkdir $out
          cat ${optionsDoc.optionsCommonMark} > $out/${snakeCase name}.md
        '';

      # Allows us to gather all options that are immediate children of `facter` and which have no child options.
      # e.g. facter.reportPath, facter.report.
      # For all other options we group them by the first immediate child of `facter`.
      # e.g. facter.bluetooth, facter.boot and so on.
      # This allows us to have a page for root facter options "facter.md", and a page each for the major sub modules.
      facterOptionsFilter =
        _:
        {
          loc ? [ ],
          options ? [ ],
          ...
        }:
        (lib.length loc) == 2 && ((lib.elemAt loc 0) == "facter") && (lib.length options) == 0;

      otherOptionsFilter = n: v: !(facterOptionsFilter n v);

      facterMarkdown = mkMarkdown "facter" (lib.filterAttrs facterOptionsFilter eval.options.facter);
      otherMarkdown = lib.mapAttrsToList mkMarkdown (
        lib.filterAttrs otherOptionsFilter eval.options.facter
      );

      optionsMarkdown = pkgs.symlinkJoin {
        name = "facter-module-markdown";
        paths = [ facterMarkdown ] ++ otherMarkdown;
      };

    in
    with pkgs;
    [
      (pkgs.writeScriptBin "mkdocs" ''
        # rsync in NixOS modules doc to avoid issues with symlinks being owned by root
        rsync -aL --chmod=u+rw --delete-before ${optionsMarkdown}/ ./docs/content/reference/nixos_modules

        # execute the underlying command
        ${pkgs.mkdocs}/bin/mkdocs "$@"
      '')
    ]
    ++ (with pkgs.python3Packages; [
      mike
      mkdocs-material
    ]);
}
