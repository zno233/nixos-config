{
  flake.modules.nixos.sessionVariables =
    { ... }:
    {
      environment.sessionVariables = {
        ELECTRON_OZONE_PLATFORM_HINT = "auto";
        NIXOS_OZONE_WL = "1"; # 强制使用 Wayland
        LIBVA_DRIVER_NAME = "iHD"; # Intel VAAPI 驱动
        VDPAU_DRIVER = "va_gl"; # 兼容老软件
        MESA_VK_WSI_PRESENT_MODE = "mailbox"; # 类似开启“三重缓冲”，减少撕裂感且低延迟
      };

    };
}
