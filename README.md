# nixos-facter-modules

> [!NOTE] > **Status: vaporware**

A series of [NixOS modules] to be used in conjunction with [NixOS Facter].

With a similar goal to [NixOS Hardware], these modules are designed around _fine-grained_ feature detection as opposed to system models.
This is made possible by the hardware report provided by [NixOS Facter].

By default, these modules enable or disable themselves based on detected hardware.

[NixOS modules]: https://wiki.nixos.org/wiki/NixOS_modules
[NixOS Facter]: https://github.com/numtide/nixos-facter
[NixOS Hardware]: https://github.com/NixOS/nixos-hardware

## Getting started

To generate a hardware report run the following:

```console
$ nix run github:numtide/nixos-facter > factor.json
```

Then use the generated `factor.json` with the NixOS module as follows:

```nix
# flake.nix
{
    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
        nixos-facter-modules.url = "github:numtide/nixos-facter-modules";
    };

    outputs = inputs @ {
        nixpkgs,
        ...
    }: {
        nixosConfigurations.basic = nixpkgs.lib.nixosSystem {
            modules = [
                inputs.nixos-facter-modules.nixosModules.facter
                { config.facter.reportPath = ./factor.json; }
                # ...
            ];
        };
    };
}
```
