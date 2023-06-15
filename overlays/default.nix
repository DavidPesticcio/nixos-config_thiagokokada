{ pkgs, flake, ... }:

let
  inherit (flake) inputs;
in
{
  nixpkgs.overlays = [
    inputs.emacs.overlay

    (final: prev: {
      # namespaces
      lib = prev.lib.extend (finalLib: prevLib:
        (import ../lib { inherit (prev) lib; })
      );

      gaming = flake.inputs.nix-gaming.packages.${pkgs.system};

      wallpapers = prev.callPackage ../packages/wallpapers { };

      # custom packages
      autorandr = prev.autorandr.overrideAttrs (_: { src = inputs.autorandr; });

      arandr = prev.arandr.overrideAttrs (_: { src = inputs.arandr; });

      anime4k = prev.callPackage ../packages/anime4k { };

      change-res = prev.callPackage ../packages/change-res { };

      home-manager = flake.inputs.home.packages.${pkgs.system}.home-manager;

      # https://lists.sr.ht/~emersion/public-inbox/patches/40604
      kanshi = prev.kanshi.overrideAttrs (oldAttrs: {
        patches = (oldAttrs.patches or [ ]) ++ [
          (prev.fetchpatch {
            url = "https://lists.sr.ht/~emersion/public-inbox/patches/40604/mbox";
            hash = "sha256-n1ZlOEWne0ALvspbwI4xUCe5MfYtyidSqYkuFmLbOCU=";
          })
        ];
      });

      open-browser = prev.callPackage ../packages/open-browser { };

      nix-whereis = prev.callPackage ../packages/nix-whereis { };

      nix-cleanup = prev.callPackage ../packages/nix-cleanup { };

      nixos-cleanup = prev.callPackage ../packages/nix-cleanup { isNixOS = true; };

      nom-rebuild = prev.callPackage ../packages/nom-rebuild { };

      run-bg-alias = name: command: prev.callPackage ../packages/run-bg-alias { inherit name command; };

      swaylock-effects = prev.swaylock-effects.overrideAttrs (oldAttrs: {
        # https://github.com/jirutka/swaylock-effects/pull/38
        patches = (oldAttrs.patches or [ ]) ++ [
          (prev.fetchpatch {
            url = "https://github.com/jirutka/swaylock-effects/commit/18573cb795592b4ab82f7693c151923d9e08cbb5.patch";
            hash = "sha256-ogFhSsONuCToLFIStUaA+GTm8qBKJrg7s6VMDBvF1Bc=";
          })
          (prev.fetchpatch {
            url = "https://github.com/jirutka/swaylock-effects/commit/071bfa4f584593de4dd91f052419767bc30d0b4b.patch";
            hash = "sha256-Tk8AXtt7eszuHe918YUNAgSGqc73mTYpZ14R6wB33Sw=";
          })
        ];
      });
    })
  ];
}
