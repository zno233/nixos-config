{
  flake.modules.nixos.steam =
    { pkgs, ... }:
    {
      programs = {
        steam = {
          enable = true;
          # package = pkgs.steam.override {
          #   extraArgs = "-system-composer";
          # };

          remotePlay.openFirewall = true;
          dedicatedServer.openFirewall = true;

          gamescopeSession.enable = true;

          # extraCompatPackages = [
          #   pkgs.proton-ge-bin
          # ];
        };

        gamescope = {
          enable = true;
          capSysNice = false;
          args = [
            "--rt"
            "--expose-wayland"
          ];
        };
        gamemode.enable = true; # 启用Gamemode，并自动激活以动态提升性能
      };

      # 启用 ntsync 模块，此为 Wine 的同步优化补丁
      boot.kernelModules = [ "ntsync" ];

      services.udev.extraRules = ''
        KERNEL=="ntsync*", MODE="0666"
      '';

      environment.systemPackages = with pkgs; [
        lutris # 支持多游戏平台
        gamemode # 提升游戏性能动态管理
        mangohud # 游戏 HUD 显示帧率等信息
        steam-run # 运行非原生Steam游戏
        protonplus # Simple Wine and Proton-based compatibility tools manager
      ];
    };
}
