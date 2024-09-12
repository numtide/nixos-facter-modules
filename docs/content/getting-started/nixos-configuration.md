# NixOS Configuration

Taking the `facter.json` file generated in the [previous step](./generate-report.md), we can construct a
[NixOS configuration]:

=== "Flake"

    ```nix title="flake.nix"
    {
      inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
        nixos-facter-modules.url = "github:numtide/nixos-facter-modules";
      };

      outputs =
        inputs@{ nixpkgs, ... }:
        let
            inherit (nixpkgs) lib;
        in
        {
          nixosConfigurations.basic = lib.nixosSystem {
            modules = [

              # enable the NixOS Facter module
              inputs.nixos-facter-modules.nixosModules.facter

              # configure the facter report
              { config.facter.reportPath = ./facter.json; }

              # Additional modules and configuration, for example:
              #
              # {
              #   users.users.root.initialPassword = "fnord23";
              #   boot.loader.grub.devices = lib.mkForce [ "/dev/sda" ];
              #   fileSystems."/".device = lib.mkDefault "/dev/sda";
              # }
              # ...
              # Define your bootloader if you are not using grub
              # { boot.loader.systemd-boot.enable = true; }
            ];
          };
        };
    }
    ```

=== "Non-Flake"

    ```nix title="configuration.nix"
    { lib, ... }:
    {
      imports = [
        "${
          (builtins.fetchTarball { url = "https://github.com/numtide/nixos-facter-modules/"; })
        }/modules/nixos/facter.nix"
      ];

      # configure the facter report
      config.facter.reportPath = ./facter.json;

      # Additional modules and configuration, for example:
      #
      # config.users.users.root.initialPassword = "fnord23";
      # config.boot.loader.grub.devices = lib.mkForce [ "/dev/sda" ];
      # config.fileSystems."/".device = lib.mkDefault "/dev/sda";
      #
      # ...
      # Define your bootloader if you are not using grub
      # config.boot.loader.systemd-boot.enable = true;
    }
    ```

The NixOS Facter module will attempt to do the following:

-   Configure `nixpkgs.hostPlatform` based on the [detected architecture].
-   Enable a variety of kernel modules and NixOS options related to VM and bare-metal environments based on the [detected virtualisation].
-   Enable CPU microcode updates based on the [detected CPU(s)].
-   Ensure a variety of kernel modules are made available at boot time based on the [detected (usb|firewire|storage) controllers and disks].
-   Enable a variety of kernel modules based on the [detected Broadcom and Intel WiFi devices].

!!! info "Roadmap"

    We continue to add to and improve [nixos-facter-modules]. Our eventual goal is to replace much if not all of the
    functionality currently provided by [nixos-hardware] and [nixos-generate-config].

[NixOS configuration]: https://nixos.org/manual/nixos/stable/#sec-configuration-syntax
[detected architecture]: https://github.com/numtide/nixos-facter-modules/blob/main/modules/nixos/system.nix
[detected virtualisation]: https://github.com/numtide/nixos-facter-modules/blob/main/modules/nixos/virtualisation.nix
[detected CPU(s)]: https://github.com/numtide/nixos-facter-modules/blob/main/modules/nixos/firmware.nix
[detected (usb|firewire|storage) controllers and disks]: (https://github.com/numtide/nixos-facter-modules/blob/main/modules/nixos/boot.nix)
[detected Broadcom and Intel WiFi devices]: https://github.com/numtide/nixos-facter-modules/blob/main/modules/nixos/networking
[nixos-facter-modules]: https://github.com/numtide/nixos-facter-modules
[nixos-hardware]: https://github.com/NixOS/nixos-hardware
[nixos-generate-config]: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/installer/tools/nixos-generate-config.pl
