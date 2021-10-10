{ config, lib, pkgs, ... }:

{
  programs.vscode = {
    enable = true;
    package = pkgs.unstable.vscodium;
    extensions = with pkgs.unstable.vscode-extensions; [
      # Clojure
      betterthantomorrow.calva

      # Go
      golang.go

      # Python
      # Broken until merged: https://github.com/NixOS/nixpkgs/pull/140564
      # ms-python.python

      # Nix
      b4dm4n.vscode-nixpkgs-fmt
      bbenoist.nix

      # VSpaceCode
      bodil.file-browser
      kahole.magit
      vscodevim.vim
      vspacecode.vspacecode
      vspacecode.whichkey
    ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      {
        name = "fuzzy-search";
        publisher = "jacobdufault";
        version = "0.0.3";
        sha256 = "sha256-oN1SzXypjpKOTUzPbLCTC+H3I/40LMVdjbW3T5gib0M=";
      }
      {
        name = "rainbow-brackets";
        publisher = "2gua";
        version = "0.0.6";
        sha256 = "sha256-TVBvF/5KQVvWX1uHwZDlmvwGjOO5/lXbgVzB26U8rNQ=";
      }
    ];
    userSettings = with builtins; fromJSON (readFile ./settings.json);
    keybindings = with builtins; fromJSON (readFile ./keybindings.json);
  };
}
