{ config, lib, ... }:

with lib; {
  options.device = {
    type = mkOption {
      type = types.enum [ "desktop" "laptop" "server" "vm" ];
      description = "Type of device";
      default = "desktop";
    };
    netDevices = mkOption {
      type = with types; listOf str;
      description = "Available net devices";
      example = [ "eno1" "wlp2s0" ];
      default = [ "eth0" ];
    };
    mountPoints = mkOption {
      type = with types; listOf path;
      description = "Available mount points";
      example = [ "/" "/mnt/backup" ];
      default =
        if (config ? fileSystems) then
          (lists.subtractLists [ "/boot" "/tmp" "/nix" "/bin" "/usr/bin" ]
            (mapAttrsToList (n: _: n) config.fileSystems))
        else
          [ "/" ];
    };
    mediaDir = mkOption {
      type = types.path;
      description = "Shared media directory";
      example = "/mnt/media";
      default = "/media";
    };
  };
}
