# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, flake, system, ... }:

let
  inherit (config.meta) username;
in
{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../nixos/minimal.nix
      ../../nixos/security.nix
      ../../nixos/ssh.nix
      ../../nixos/vps.nix
      flake.inputs.home.nixosModules.home-manager
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
      inherit flake system;
      super = config;
    };
  };

  device.type = "server";

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/vda"; # or "nodev" for efi only

  # Enable IPv6
  boot.kernel.sysctl = {
    "net.ipv6.conf.ens3.autoconf" = 0;
    "net.ipv6.conf.ens3.accept_ra" = 0;
  };

  networking.hostName = "mirai-vps";
}
