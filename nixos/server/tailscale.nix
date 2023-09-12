{ lib, config, pkgs, ... }:

let
  inherit (config.meta) username;
  inherit (config.services.tailscale) interfaceName port;
in
{
  options.nixos.server.tailscale.enable = lib.mkEnableOption "Tailscale config (server side)";

  config = lib.mkIf config.nixos.server.tailscale.enable {
    environment.systemPackages = with pkgs; [ tailscale ];

    networking.firewall = {
      # always allow traffic from your Tailscale network
      trustedInterfaces = [ interfaceName ];

      # allow the Tailscale UDP port through the firewall
      allowedUDPPorts = [ port ];
    };

    services.tailscale = {
      enable = true;
      permitCertUid = toString config.users.users.${username}.uid;
      useRoutingFeatures = lib.mkDefault "server";
      extraUpFlags = [
        "--advertise-exit-node"
        "--ssh"
      ];
    };

    # Ignore Tailscale interface to workaround wait-online issue
    # See: https://github.com/NixOS/nixpkgs/issues/180175
    systemd.network.networks.${interfaceName}.linkConfig = {
      Unmanaged = true;
    };
  };
}
