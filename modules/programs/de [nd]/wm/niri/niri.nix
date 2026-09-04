{
  self,
  inputs,
  ...
}:
{
  flake-file.inputs = {
    niri = {
      url = "github:epireyn/niri-flake";
    };
  };

  flake.modules.nixos.niri =
    {
      pkgs,
      ...
    }:
    {
      home-manager.sharedModules = [
        inputs.self.modules.homeManager.niri
      ];

      nixpkgs = {
        overlays = [ self.inputs.niri.overlays.niri ];
      };

      services.displayManager.sessionPackages = [ pkgs.niri-unstable ];
    };

  flake.modules.homeManager.niri =
    {
      config,
      pkgs,
      ...
    }:
    let
      niriConfig = "${config.home.homeDirectory}/zno-config/modules/programs/de [nd]/wm/niri/config";
    in
    {
      imports = [
        self.inputs.niri.homeModules.niri
      ];

      programs.niri = {
        enable = true;
        package = pkgs.niri-unstable;
      };

      home = {
        packages = with pkgs; [
          jaq
          xwayland-satellite
          wl-clipboard # 核心剪贴板工具
          cliphist # 剪贴板历史记录
          grim # Wayland 截图工具
          kotonoha # wayland 桌面歌词
          # slurp # 屏幕区域选择工具
          # satty # 截图标注工具（支持绘图、箭头、文字等）
          # hyprpicker # 取色器
          # linux-wallpaperengine # 壁纸引擎

          # waybar       # 面板
          # swww         # 壁纸
          # swaynotificationcenter      # 通知中心
          # wf-recorder  # Wayland屏幕录制工具
        ];
      };
      xdg.configFile."niri/config.kdl" = {
        source = ./config/config.kdl;
      };
      xdg.configFile."niri/binds.kdl" = {
        source = ./config/binds.kdl;
      };
      xdg.configFile."niri/environment.kdl" = {
        source = ./config/environment.kdl;
      };
      xdg.configFile."niri/noctalia-shell.kdl" = {
        source = ./config/noctalia-shell.kdl;
      };
      xdg.configFile."niri/recent-windows.kdl" = {
        source = ./config/recent-windows.kdl;
      };
      xdg.configFile."niri/waybar.kdl" = {
        source = ./config/waybar.kdl;
      };
      xdg.configFile."niri/window-rule.kdl" = {
        source = ./config/window-rule.kdl;
      };
      xdg.configFile."niri/patch.kdl" = {
        source = config.lib.file.mkOutOfStoreSymlink "${niriConfig}/patch.kdl";
        force = true;
      };
      xdg.configFile."niri/animations" = {
        source = config.lib.file.mkOutOfStoreSymlink "${niriConfig}/animations";
        force = true;
      };
    };
}
