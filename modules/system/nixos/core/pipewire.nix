{ config, pkgs, ... }:

{
  # PipeWire 实时调度支持
  security.rtkit.enable = true;

  # PipeWire 栈
  services.pipewire = {
    enable = true;

    alsa.enable = true;
    alsa.support32Bit = true;

    pulse.enable = true;
    jack.enable = true;

    wireplumber.enable = true;
  };

  # ALSA 音量持久化（笔记本友好）
  hardware.alsa.enablePersistence = true;

  # 必要工具
  environment.systemPackages = with pkgs; [
    easyeffects
  ];
}
