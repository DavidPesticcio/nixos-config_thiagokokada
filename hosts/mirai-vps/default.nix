# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, self, system, ... }:

let
  inherit (config.meta) username;
in
{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../nixos/cli.nix
      ../../nixos/meta.nix
      ../../nixos/security.nix
      ../../nixos/ssh.nix
      ../../nixos/system.nix
      ../../nixos/user.nix
      ../../nixos/vps.nix
      ../../modules/device.nix
      ../../modules/meta.nix
      ../../cachix.nix
      ../../overlays
      self.inputs.home.nixosModules.home-manager
    ];

  home-manager = {
    useUserPackages = true;
    users.${username} = {
      imports = [
        ../../home-manager/irssi.nix
        ../../home-manager/minimal.nix
      ];
    };
    extraSpecialArgs = {
      inherit self system;
      super = config;
    };
  };

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/vda"; # or "nodev" for efi only

  networking.hostName = "mirai-vps";
}
