{
  inputs,
  ...
}:
{
  # NixOS 侧：nixpkgs 已自带 programs.umbriel 模块（包、wayland session、
  # xdg-desktop-portal-umbriel、systemd 单元都由它负责），此处只做
  # 会话级接线，结构与 niri 保持一致。
  flake.modules.nixos.umbriel = {
    home-manager.sharedModules = [
      inputs.self.modules.homeManager.umbriel
    ];

    programs.umbriel.enable = true;

    # 与 niri 模块对称：按会话声明 portal 后端路由。
    # xdg-desktop-portal-umbriel 自身提供的 extraPortals / configPackages
    # 已由 programs.umbriel 自动注册，这里只做接口级路由。
    xdg.portal.config.umbriel = {
      default = [
        "umbriel"
        "gtk"
      ];
      "org.freedesktop.impl.portal.ScreenCast" = "umbriel";
      "org.freedesktop.impl.portal.Screenshot" = "umbriel";
      "org.freedesktop.impl.portal.Secret" = "gnome-keyring";
    };
  };

  flake.modules.homeManager.umbriel =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      umbrielConfig = "${config.home.homeDirectory}/zno-config/modules/programs/de [nd]/wm/umbriel/config";
    in
    {
      home.packages = with pkgs; [
        wl-clipboard # 核心剪贴板工具
        cliphist # 剪贴板历史记录
        grim # Wayland 截图工具
        slurp # 区域截图选区
      ];

      # config/ 目录里的东西全部 store 拷贝（新增文件不用改这里）；
      # 只有 patch.toml 覆盖成仓库软链，改完保存即热重载。
      xdg.configFile =
        lib.mapAttrs' (name: _: lib.nameValuePair "umbriel/${name}" { source = ./config + "/${name}"; }) (
          builtins.readDir ./config
        )
        // {
          "umbriel/patch.toml" = {
            source = config.lib.file.mkOutOfStoreSymlink "${umbrielConfig}/patch.toml";
            force = true;
          };
        };
    };
}
