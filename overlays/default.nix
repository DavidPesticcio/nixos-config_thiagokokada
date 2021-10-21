{ pkgs, lib, self, system, ... }:

let
  inherit (self) inputs;
in
{
  nixpkgs.overlays = [
    inputs.emacs.overlay

    (final: prev: {
      unstable = import inputs.unstable {
        inherit system;
        config = prev.config;
      };

      emacs-custom = with final; (emacsPackagesGen emacsPgtkGcc).emacsWithPackages
        (epkgs: with epkgs; [ vterm ]);

      linux-zen-with-muqss = with prev;
        linuxPackagesFor (linux_zen.override {
          structuredExtraConfig = with lib.kernel; {
            PREEMPT = yes;
            PREEMPT_VOLUNTARY = lib.mkForce no;
            SCHED_MUQSS = yes;
          };
          ignoreConfigErrors = true;
        });

      open-browser = prev.callPackage ../packages/open-browser { };

      nix-whereis = prev.callPackage ../packages/nix-whereis { };

      nixos-cleanup = prev.callPackage ../packages/nixos-cleanup { };

      # TODO: on 21.11, use programs.htop.package instead
      htop = prev.htop.overrideAttrs (oldAttrs: rec {
        pname = "htop-vim";
        version = self.inputs.htop-vim.shortRev;
        src = self.inputs.htop-vim;
      });

      # TODO: remove it from 21.11
      pamixer = final.unstable.pamixer;
      rar = final.unstable.rar;
    })
  ];
}
