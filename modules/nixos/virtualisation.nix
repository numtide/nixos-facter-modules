{
  lib,
  config,
  options,
  ...
}:
let
  inherit (config.facter) report;
  cfg = config.facter.virtualisation;
in
{
  options.facter.virtualisation = {
    virtio_scsi.enable = lib.mkEnableOption "Enable the Facter Virtualisation Virtio SCSI module" // {
      default = lib.any (
        { vendor, device, ... }:
        # vendor (0x1af4) Red Hat, Inc.
        (vendor.value or 0) == 6900
        &&
          # device (0x1004, 0x1048) Virtio SCSI
          (lib.elem (device.value or 0) [
            4100
            4168
          ])
      ) (report.hardware.scsi or [ ]);
      defaultText = "hardware dependent";
    };
    oracle.enable = lib.mkEnableOption "Enable the Facter Virtualisation Oracle module" // {
      default = report.virtualisation == "oracle";
      defaultText = "environment dependent";
    };
    parallels.enable = lib.mkEnableOption "Enable the Facter Virtualisation Parallels module" // {
      default = report.virtualisation == "parallels";
      defaultText = "environment dependent";
    };
    qemu.enable = lib.mkEnableOption "Enable the Facter Virtualisation Qemu module" // {
      default = builtins.elem report.virtualisation [
        "qemu"
        "kvm"
        "bochs"
      ];
      defaultText = "environment dependent";
    };
    hyperv.enable = lib.mkEnableOption "Enable the Facter Virtualisation Hyper-V module" // {
      default = report.virtualisation == "microsoft";
      defaultText = "environment dependent";
    };
    # no virtualisation detected
    none.enable = lib.mkEnableOption "Enable the Facter Virtualisation None module" // {
      default = report.virtualisation == "none";
      defaultText = "environment dependent";
    };
  };

  config = {

    # KVM support
    boot.kernelModules =
      with lib;
      let
        cpus = report.hardware.cpu or [ ];
      in
      unique (flatten [
        (optionals (any (
          {
            features ? [ ],
            ...
          }:
          elem "vmx" features
        ) cpus) [ "kvm-intel" ])
        (optionals (any (
          {
            features ? [ ],
            ...
          }:
          elem "svm" features
        ) cpus) [ "kvm-amd" ])
      ]);

    # virtio & qemu
    boot.initrd = {
      kernelModules = lib.optionals cfg.qemu.enable [
        "virtio_balloon"
        "virtio_console"
        "virtio_rng"
        "virtio_gpu"
      ];

      availableKernelModules =
        (lib.optionals cfg.qemu.enable [
          "virtio_net"
          "virtio_pci"
          "virtio_mmio"
          "virtio_blk"
          "9p"
          "9pnet_virtio"
        ])
        ++ (lib.optionals cfg.virtio_scsi.enable [ "virtio_scsi" ]);
    };

    virtualisation = {
      # oracle
      virtualbox.guest.enable = cfg.oracle.enable;
      # hyper-v
      hypervGuest.enable = cfg.hyperv.enable;
    };

    # parallels
    hardware.parallels.enable = cfg.parallels.enable;
    nixpkgs.config = lib.mkIf (!options.nixpkgs.pkgs.isDefined) {
      allowUnfreePredicate = lib.mkIf cfg.parallels.enable (
        pkg: builtins.elem (lib.getName pkg) [ "prl-tools" ]
      );
    };
  };
}
