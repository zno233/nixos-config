{ config, pkgs, lib, ... }:
{
  # 1. 启用 systemd-oomd 守护进程
  systemd.oomd = {
    enable = true;
    enableUserSlices = true; # 监控用户进程
  };

  # 2. 为 Niri 所在的 slice 设置内存压力阈值
  # 当内存压力 (PSI) 超过 4% 且持续 20 秒，或者瞬时压力过大时，oomd 会介入
  systemd.slices."user".sliceConfig = {
    ManagedOOMMemoryPressure = "kill";
    ManagedOOMMemoryPressureLimit = "40%";
  };
}
