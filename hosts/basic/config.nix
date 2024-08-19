_: {
  boot = {
    growPartition = true;
    kernelParams = [ "console=ttyS0" ];
    loader = {
      timeout = 0;
      grub.device = "/dev/vda";
    };
  };

  fileSystems."/" = {
    device = "/dev/vda";
    autoResize = true;
    fsType = "ext4";
  };

  boot.tmp.cleanOnBoot = true;
  boot.initrd.systemd.enable = true;
  # Enable this to have a shell access in initrd
  boot.initrd.systemd.emergencyAccess = false;

  users.users.facter = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };
  services.getty.autologinUser = "facter";
  security.sudo.wheelNeedsPassword = false;

  system.stateVersion = "24.05";

  virtualisation.vmVariant = {
    virtualisation = {
      graphics = false;
      cores = 2;
      diskSize = 1024 * 10;
      memorySize = 1024 * 2;
      sharedDirectories.facter = {
        source = "$DATA_DIR";
        target = "/mnt/shared";
      };
    };
  };
}
