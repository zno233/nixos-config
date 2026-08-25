{
  inputs,
  ...
}:
{
  flake.modules.nixos.linux-laptop =
    { pkgs, ... }:
    {

      imports = with inputs.self.modules.nixos; [
        laptop-power
        firmware
        services-fs
      ];

      boot = {
        kernelParams = [
          # nvidia驱动相关
          "module_blacklist=nova_core,nova,nouveau"
          # "nvidia-drm.modeset=1" # hardware.nvidia 模块会自动加

          # intel集显相关
          "i915.enable_guc=3" # 开启调度和视频加速
          "i915.enable_fbc=1" # 帧缓冲压缩
          # "i915.enable_psr=0" # 禁用 PSR 防止 Wayland 闪屏
          "i915.guc_log_level=-1" # 禁用日志，减少中断负担
        ];
      };

      services = {
        # intel温控
        thermald.enable = true;
      };
    };
}
