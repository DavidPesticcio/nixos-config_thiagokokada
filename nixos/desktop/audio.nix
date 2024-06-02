{ config, lib, pkgs, ... }:

let
  cfg = config.nixos.desktop.audio;
in
{
  options.nixos.desktop.audio = {
    enable = lib.mkEnableOption "audio config" // {
      default = config.nixos.desktop.enable;
    };
    lowLatency = {
      enable = lib.mkEnableOption "low latency config" // {
        default = config.nixos.games.enable;
      };
      quantum = lib.mkOption {
        description = "Quantum.";
        type = lib.types.int;
        default = 128;
        example = 32; # lowest latency possible
      };
      rate = lib.mkOption {
        description = "Audio rate.";
        type = lib.types.int;
        default = 48000;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # This allows PipeWire to run with realtime privileges (i.e: less cracks)
    security.rtkit.enable = true;

    services = {
      pipewire = {
        enable = true;
        audio.enable = true;
        alsa = {
          enable = true;
          support32Bit = true;
        };
        pulse.enable = true;
        extraConfig.pipewire."92-low-latency" = lib.mkIf cfg.lowLatency.enable {
          context.properties = {
            default.clock.rate = cfg.lowLatency.rate;
            default.clock.quantum = cfg.lowLatency.quantum;
            default.clock.min-quantum = cfg.lowLatency.quantum;
            default.clock.max-quantum = cfg.lowLatency.quantum;
          };
        };
        wireplumber = {
          enable = true;
          configPackages =
            let
              properties = lib.generators.toLua { } {
                "bluez5.enable-sbc-xq" = true;
                "bluez5.enable-msbc" = true;
                "bluez5.enable-hw-volume" = true;
                "bluez5.headset-roles" = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]";
              };
            in
            [
              (pkgs.writeTextDir "share/wireplumber/bluetooth.lua.d/51-bluez-config.lua" /* lua */ ''
                bluez_monitor.properties = ${properties}
              '')
            ];
        };
      };
    };
  };
}
