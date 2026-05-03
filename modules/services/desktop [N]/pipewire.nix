{
  flake.modules.nixos.pipewire =
    { pkgs, ... }:
    {
      # ==================== PipeWire 核心配置 ====================
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        jack.enable = true;
        wireplumber.enable = true;

        # 日常使用推荐的平衡设置（稳定 + 较低延迟）
        extraConfig.pipewire."92-low-latency" = {
          "context.properties" = {
            "default.clock.allowed-rates" = [
              44100
              48000
              96000
            ];
            "default.clock.rate" = 48000; # Fixed rate avoids resampling latency
            "default.clock.quantum" = 128; # ~5ms latency at 48kHz
            "default.clock.min-quantum" = 64; # ~2.5ms latency at 48kHz
            "default.clock.max-quantum" = 512;
          };
        };

        # Crucial: Match low-latency for PulseAudio clients (browsers, Steam/Rocksmith)
        extraConfig.pipewire-pulse."92-low-latency" = {
          "pulse.properties" = {
            "pulse.min.req" = "64/48000"; # Start with 64, not 32, for stability
            "pulse.default.req" = "64/48000";
            "pulse.max.req" = "128/48000";
          };
        };
      };

      # ==================== 实时权限 ====================
      security.rtkit.enable = true;

      security.pam.loginLimits = [
        {
          domain = "@audio";
          item = "memlock";
          type = "-";
          value = "unlimited";
        }
        {
          domain = "@audio";
          item = "rtprio";
          type = "-";
          value = "80";
        }
        {
          domain = "@audio";
          item = "nice";
          type = "-";
          value = "-10";
        }
      ];

      # ==================== 内核 & 硬件优化 ====================
      boot.kernelParams = [
        "threadirqs"
      ];

      # ==================== 日常实用工具 ====================
      environment.systemPackages = with pkgs; [
        pavucontrol # 音量控制工具
        easyeffects # 用于音效处理
        crosspipe # 可视化连线工具，排查问题极快
      ];
    };
}
