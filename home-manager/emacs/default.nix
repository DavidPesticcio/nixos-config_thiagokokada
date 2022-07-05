{ self, config, lib, pkgs, ... }:

{
  imports = [ self.inputs.nix-doom-emacs.hmModule ];

  # Emacs overlay
  home = {
    packages = with pkgs; [
      (run-bg-alias "em" "${config.programs.doom-emacs.package}/bin/emacs")
      # font for my config
      fira-code
      hack-font
      noto-fonts

      # markdown mode
      pandoc

      # lsp
      unstable.rnix-lsp

      # shell
      shellcheck
    ];
  };

  programs.doom-emacs = {
    enable = true;
    doomPrivateDir = ./doom-emacs;
    emacsPackage = with pkgs;
      if stdenv.isDarwin then
        emacsNativeComp
      else emacsPgtkNativeComp;
    extraPackages = with pkgs; [
      fd
      findutils
      ripgrep
    ];
  };
}
