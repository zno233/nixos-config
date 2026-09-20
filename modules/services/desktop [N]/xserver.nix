{
  flake.modules.nixos.xserver =
    { ... }:
    {
      services = {
        xserver = {
          enable = true;
          xkb.layout = "us";
          exportConfiguration = true;
        };

        libinput = {
          enable = true;
        };
      };

      # To prevent getting stuck at shutdown
      systemd.settings.Manager.DefaultTimeoutStopSec = "10s";
    };
}
