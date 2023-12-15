{ config, pkgs, lib, ... }:

let
  cfg = config.home-manager.cli;
in
{
  imports = [
    ./git.nix
    ./htop.nix
    ./irssi.nix
    ./nixpkgs.nix
    ./nnn.nix
    ./ssh.nix
    ./tmux.nix
    ./zsh.nix
  ];

  options.home-manager.cli = {
    enable = lib.mkEnableOption "CLI config" // { default = true; };
    enableGnu = lib.mkEnableOption "GNU utils config" // {
      default = !pkgs.stdenv.isDarwin;
    };
    enableOuch = lib.mkEnableOption "Ouch config" // {
      default = !pkgs.stdenv.isDarwin;
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      _7zz
      aria2
      bc
      bind.dnsutils
      curl
      dialog
      dos2unix
      dua
      each
      file
      hyperfine
      ix
      jq
      less
      lsof
      mediainfo
      page
      procps
      pv
      python3
      ripgrep
      rlwrap
      tealdeer
      tig
      tokei
      wget
    ]
    ++ lib.optionals cfg.enableOuch [
      ouch
    ]
    ++ lib.optionals cfg.enableGnu [
      coreutils
      diffutils
      findutils
      gawk
      gcal
      gnugrep
      gnumake
      gnused
      inetutils
      netcat-gnu
    ];

    programs = {
      bat = {
        enable = true;
        extraPackages = with pkgs.bat-extras; [ batdiff batman batgrep batwatch ];
      };
      zsh.shellAliases = {
        # For muscle memory...
        archive = lib.mkIf cfg.enableOuch "${lib.getExe pkgs.ouch} compress";
        unarchive = lib.mkIf cfg.enableOuch "${lib.getExe pkgs.ouch} decompress";
        lsarchive = lib.mkIf cfg.enableOuch "${lib.getExe pkgs.ouch} list";
        cal = lib.mkIf cfg.enableGnu (lib.getExe' pkgs.gcal "gcal");
        ncdu = "${lib.getExe pkgs.dua} interactive";
        sloccount = lib.getExe pkgs.tokei;
      };
    };
  };
}
