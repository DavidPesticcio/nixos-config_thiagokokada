# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  device.type = "notebook";
  device.mountPoints = [ "/" ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelParams = [ "pci=noaer" ];

  networking.hostName = "mikudayo-nixos";

  services.xserver = {
    layout = "br,us";
    xkbVariant = "abnt2,intl";
  };
}
