{
  flake.modules.nixos.sessionVariables =
    { ... }:
    {
      environment.sessionVariables = {
        ELECTRON_OZONE_PLATFORM_HINT = "auto";
        NIXOS_OZONE_WL = "1"; # 强制使用 Wayland
        # LIBVA_DRIVER_NAME = "iHD"; # Intel VAAPI 驱动

        XCURSOR_THEME = "Bibata-Modern-Ice";
      };
    };
}
