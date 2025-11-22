# /etc/nixos/modules/audio.nix

{ config, pkgs, ... }:

{
  # 禁用旧的 PulseAudio，避免冲突
  services.pulseaudio.enable = false;

  # 实时内核访问权限，对 PipeWire 音频性能非常关键
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true; # 启用 PipeWire 的 PulseAudio 兼容层
    
    # 启用 PipeWire 对蓝牙设备的支持
    wireplumber.enable = true;
    
    # lowLatency.enable = true; # 您原有的注释行
  };
  
  # ALSA 持久化 (保留)
  hardware.alsa.enablePersistence = true;

  # 修正：既然使用 PipeWire，就不需要安装 pulseaudioFull
  # 移除此行，使其为空列表
  environment.systemPackages = [ ];
}
