{ pkgs, ... }:
{
  services = {
    gvfs.enable = true;

    gnome = {
      tinysparql.enable = true;
      gnome-keyring.enable = true;
    };

    dbus.enable = true;
    fstrim.enable = true;
    irqbalance.enable = true;  # 提升 IRQ 响应

    # needed for GNOME services outside of GNOME Desktop
    dbus.packages = with pkgs; [
      gcr
      gnome-settings-daemon
    ];

    logind = {
      settings.Login = {
        # don’t shutdown when power button is short-pressed
        HandlePowerKey = "ignore";
      };
    };

    udisks2.enable = true;   
    seatd.enable = true;
  };
  
}
