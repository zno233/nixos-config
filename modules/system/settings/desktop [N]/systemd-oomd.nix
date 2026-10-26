{
  flake.modules.nixos.systemd-oomd = {
    # 启用 systemd-oomd 防止内存耗尽导致系统挂起
    systemd.oomd = {
      enable = true;
      enableRootSlice = true;
      enableUserSlices = true;
      settings.OOM = {
        DefaultMemoryPressureDurationSec = "30s";
        # zram 架构下 swap 快速填充是预期行为而非事故，
        # 90% 的 swap 规则会误杀应用；设为 100% 实际禁用 swap 规则，
        # 防挂起由 PSI 内存压力规则（user/system slice）承担
        SwapUsedLimit = "100%";
      };
    };
    # OOM 时保护 session.slice（终端/DE 通信链路）
    # 对齐 CachyOS 10-ignore-session-slice.conf
    systemd.slices."session.slice".sliceConfig.ManagedOOMPreference = "omit";
  };
}
