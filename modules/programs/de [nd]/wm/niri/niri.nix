{
  inputs,
  ...
}:
{
  flake-file.inputs = {
    niri = {
      url = "github:epireyn/niri-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nixpkgs-stable.follows = "nixpkgs-stable";
      };
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
        overlays = [ inputs.niri.overlays.niri ];
      };

      services.displayManager.sessionPackages = [ pkgs.niri-unstable ];

      # niri 不提供自己的 portal：截图 / 屏幕共享 / 远程桌面走 GNOME 实现，
      # Secret 走 gnome-keyring；其余接口交给 gtk（gtk 由 nixos.xdg 提供）。
      # 这样只有启用 niri 时才会装上 xdg-desktop-portal-gnome。
      xdg.portal = {
        extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
        config.niri = {
          # Use xdg-desktop-portal-gtk for every portal interface...
          default = [
            "gtk"
            "gnome"
          ];
          "org.freedesktop.impl.portal.ScreenCast" = "gnome";
          "org.freedesktop.impl.portal.Screenshot" = "gnome";
          "org.freedesktop.impl.portal.RemoteDesktop" = "gnome";
          "org.freedesktop.impl.portal.Secret" = "gnome-keyring";
        };
      };

      # niri-flake 的二进制缓存
      nix.settings = {
        substituters = [ "https://niri-epireyn.cachix.org?priority=60" ];
        trusted-public-keys = [
          "niri-epireyn.cachix.org-1:tlVyFN7CtsDT+ZcLPS+ekFWeT1X6X4OqvWqbBMyIzFA="
        ];
      };
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
        inputs.niri.homeModules.niri
      ];

      programs.niri = {
        enable = true;
        package = pkgs.niri-unstable;
      };

      home = {
        packages = with pkgs; [
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
      xdg.configFile."niri/clavis-shell.kdl" = {
        source = ./config/clavis-shell.kdl;
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
