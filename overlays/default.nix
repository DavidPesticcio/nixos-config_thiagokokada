{ pkgs, lib, self, system, ... }:

let
  inherit (self) inputs;
in
{
  nixpkgs.overlays = [
    inputs.emacs.overlay
    inputs.nix-cage.overlay

    (final: prev: {
      unstable = import inputs.unstable {
        inherit system;
        config = prev.config;
      };

      open-browser = prev.callPackage ../packages/open-browser { };

      nix-whereis = prev.callPackage ../packages/nix-whereis { };

      nixos-cleanup = prev.callPackage ../packages/nixos-cleanup { };

      nixpkgs-review-cage = prev.callPackage ../packages/nixpkgs-review-cage { };
    })
  ];
}
