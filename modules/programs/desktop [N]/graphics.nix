{
  flake.modules.nixos.graphics =
    { pkgs, ... }:
    {
      hardware.graphics = {
        # 启用图形支持
        enable = true;

        # 启用 32 位支持
        enable32Bit = true;

        # 将 VA-API 包和 Mesa (OpenGL/Vulkan) 包合并到同一个 extraPackages 列表
        extraPackages = with pkgs; [
          intel-media-driver # VA-API
          libvdpau-va-gl # VA-API
          vpl-gpu-rt
        ];

        # 32 位包也合并到 extraPackages32
        extraPackages32 = with pkgs.pkgsi686Linux; [
          intel-media-driver # 32 位 VA-API
          libvdpau-va-gl
        ];
      };

      # 硬件固件支持
      hardware.enableRedistributableFirmware = true;

      # 调试工具
      environment.systemPackages = with pkgs; [
        vulkan-tools
        mesa-demos
        libva-utils
        vdpauinfo
      ];
    };
}
