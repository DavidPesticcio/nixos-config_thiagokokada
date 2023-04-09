# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, flake, lib, ... }:

let
  inherit (flake) inputs;
in
{
  imports = [
    ./hardware-configuration.nix
    ../../nixos
    ../../nixos/cross-compiling.nix
    ../../nixos/games.nix
    inputs.hardware.nixosModules.lenovo-thinkpad-t14-amd-gen1
  ];

  device = {
    type = "laptop";
    netDevices = [ "enp2s0f0" "enp5s0" "wlan0" ];
    # This system is using btrfs subvolumes, so there is only root
    mountPoints = [ "/" ];
  };

  # Use the systemd-boot EFI boot loader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  specialisation = {
    "HDMI-A-1_1440p_100Hz".configuration = {
      boot.kernelParams = [
        "video=HDMI-A-1:3440x1440@99.98"
        "video=eDP-1:d"
      ];
    };
  };

  boot.initrd.luks.devices = {
    root = {
      device = "/dev/disk/by-uuid/6e4e7379-5faf-494e-9cc4-c1e379741306";
      preLVM = true;
      allowDiscards = true;
    };
  };

  boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;

  fileSystems."/".options = [ "compress=zstd" ];
  fileSystems."/home".options = [ "compress=zstd" ];
  fileSystems."/nix".options = [ "compress=zstd" "noatime" ];

  networking.hostName = "sankyuu-nixos";

  # Use ultrawide wallpaper
  home-manager.users.${config.meta.username}.theme.wallpaper.path = pkgs.wallpapers.hatsune-miku_stylized-ultrawide;

  services.tlp.settings = {
    # Set battery thresholds
    START_CHARGE_THRESH_BAT0 = 75;
    STOP_CHARGE_THRESH_BAT0 = 80;
    # Use `tlp setcharge` to restore the charging thresholds
    RESTORE_THRESHOLDS_ON_BAT = 1;
    # Increase performance on AC
    PLATFORM_PROFILE_ON_AC = "performance";
    PLATFORM_PROFILE_ON_BAT = "balanced";
    # Use schedutil governor
    CPU_SCALING_GOVERNOR_ON_AC = "schedutil";
    CPU_SCALING_GOVERNOR_ON_BAT = "schedutil";
  };

  # Used for firmware updates
  services.fwupd.enable = true;

  # The audio device from this notebook doesn't seem to like short buffers too much
  services.pipewire.lowLatency.quantum = 128;

  # https://gitlab.freedesktop.org/pipewire/pipewire/-/issues/1849
  systemd.services.fix-mic-light = {
    description = "Disables mic light (turned on by default)";
    script = ''
      echo 0 > /sys/class/leds/platform\:\:micmute/brightness
    '';
    serviceConfig.Type = "oneshot";
    wantedBy = [ "multi-user.target" ]; # starts after login
  };

  time.timeZone = "Europe/Dublin";
}
