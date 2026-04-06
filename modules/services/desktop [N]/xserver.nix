{
  flake.modules.nixos.xserver =
    { ... }:
    {
      services = {
        xserver = {
          enable = true;
          xkb.layout = "us";
          exportConfiguration = true;
          videoDrivers = [
            "modesetting"
            "nvidia"
          ];
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
