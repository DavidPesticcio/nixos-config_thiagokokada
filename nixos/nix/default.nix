{ config, lib, pkgs, flake, ... }:

{
  imports = [
    ../../cachix.nix
    ../../overlays
    ./cross-compiling.nix
  ];

  options.nixos.nix.enable = lib.mkDefaultOption "nix/nixpkgs config";

  config = lib.mkIf config.nixos.nix.enable {
    # Add some Nix related packages
    environment.systemPackages = with pkgs; [
      nixos-cleanup
      nom-rebuild
    ];

    nix = lib.mkMerge [
      (import ../../shared/nix.nix { inherit pkgs flake; })
      {
        gc = {
          automatic = true;
          persistent = true;
          randomizedDelaySec = "15m";
          dates = "3:15";
          options = "--delete-older-than 7d";
        };
        # Reduce disk usage
        daemonIOSchedClass = "idle";
        # Leave nix builds as a background task
        daemonCPUSchedPolicy = "idle";
      }
    ];

    # Enable unfree packages
    nixpkgs.config.allowUnfree = true;

    # Change build dir to /var/tmp
    systemd.services.nix-daemon = {
      environment.TMPDIR = lib.mkDefault "/var/tmp";
    };

    # This value determines the NixOS release with which your system is to be
    # compatible, in order to avoid breaking some software such as database
    # servers. You should change this only after NixOS release notes say you
    # should.
    system.stateVersion = lib.mkDefault "23.11"; # Did you read the comment?
  };
}
