{ config, pkgs, ... }:

{
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;

    # 允许 44.1k 和 48k 切换以避免重采样损失音质
    extraConfig.pipewire."10-clock-settings" = {
      "context.properties" = {
        "default.clock.allowed-rates" = [
          44100
          48000
          96000
          192000
        ];
      };
    };
  };

  # 音频工具
  environment.systemPackages = with pkgs; [
    easyeffects # 用于音效处理
    crosspipe # 可视化连线工具，排查问题极快
  ];
}
