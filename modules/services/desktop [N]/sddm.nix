{
  flake.modules.nixos.sddm =
    { pkgs, ... }:
    {
      services.displayManager = {
        sddm = {
          enable = true;
          wayland.enable = true;
          theme = "sddm-astronaut";
        };
        # 默认选择niri
        sessionPackages = [ pkgs.niri ];
        defaultSession = "niri";
      };

      security.pam.services.sddm.enableGnomeKeyring = true;

      environment.systemPackages = [
        pkgs.sddm-astronaut
      ];
    };
}
