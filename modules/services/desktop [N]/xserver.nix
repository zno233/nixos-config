{
  flake.modules.nixos.xserver =
    { ... }:
    {
      services = {
        xserver = {
          enable = true;
          xkb.layout = "us";
          exportConfiguration = true;
          # 视频驱动按平台在各主机 hardware.nix 中声明
          # (如 linux-laptop 的 modesetting/nvidia,见 hosts/linux-laptop [N]/hardware.nix)
        };

        #displayManager.autoLogin = {
        #  enable = true;
        #  user = "${username}";
        #};
        libinput = {
          enable = true;
        };
      };
      # To prevent getting stuck at shutdown
      systemd.settings.Manager.DefaultTimeoutStopSec = "10s";
    };
}
