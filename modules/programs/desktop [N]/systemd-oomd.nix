{
  flake.modules.nixos.systemd-oomd =
    { ... }:
    {
      # 启用 systemd-oomd 防止内存耗尽导致系统挂起
      systemd.oomd = {
        enable = true;
        enableRootSlice = true;
        enableUserSlices = true;
        # 当 swap 使用率 > 90% 或内存压力持续 30 秒时触发
        settings.OOM = {
          DefaultMemoryPressureDurationSec = "30s";
        };
      };
    };
}
