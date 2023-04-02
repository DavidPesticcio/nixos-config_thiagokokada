{ ... }:

{
  imports = [
    ./cli.nix
    ./desktop.nix
    ./emacs
    ./git.nix
    ./helix.nix
    ./hexchat.nix
    ./htop.nix
    ./i3
    ./kitty.nix
    ./meta
    ./mpv
    ./neovim.nix
    ./nixpkgs.nix
    ./nnn.nix
    ./non-nix.nix
    ./ssh.nix
    ./sway
    ./theme
    ./tmux.nix
    ./vscode
    ./xterm.nix
    ./zsh.nix
  ];

  systemd.user.startServices = "sd-switch";
}
