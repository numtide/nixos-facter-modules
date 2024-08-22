{ pkgs, ... }:
{
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

  nix = {
    settings = {
      fallback = true;
      experimental-features = "nix-command flakes";

      substituters = [
        "https://nix-community.cachix.org"
        "https://numtide.cachix.org"
      ];

      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
      ];
    };
    registry = {
      nixpkgs.to = {
        type = "path";
        inherit (pkgs) path;
      };
      nixos-facter.to = {
        type = "github";
        owner = "numtide";
        repo = "nixos-facter";
      };
    };
  };

  virtualisation.vmVariant = {
    virtualisation = {
      graphics = false;
      cores = 2;
      diskSize = 1024 * 10;
      memorySize = 1024 * 2;
      sharedDirectories.facter = {
        source = "$PRJ_DATA_DIR";
        target = "/mnt/shared";
      };
    };
  };
}
