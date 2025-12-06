{ 
  pkgs, 
  inputs,
  username,
  host,
  config,
  ... 
}:
  let
    # 内部定义这些变量，从 inputs 中获取
    caelestia-shell = inputs.caelestia-shell; # 假设 flake input 的名称是 caelestia-shell
    caelestia-cli   = inputs.caelestia-cli;
  in
{
  # 导入官方 Caelestia HM 模块
  imports = [ caelestia-shell.homeManagerModules.default ];

  # ---------- Caelestia ----------
  programs.caelestia = {
    enable = true;
     systemd = {
       enable = false; # if you prefer starting from your compositor
       target = "graphical-session.target";
       environment = [];
    };
    # 推荐：with-cli 包 = shell + cli
    package = caelestia-shell.packages.${pkgs.system}.with-cli;

    # CLI 主题同步
    cli = {
      enable = true;
      settings = {
        theme = {
          enableGtk       = true;
          enableQt        = true;
          enableHypr      = true;
          enableSpicetify = true;
          enableDiscord   = true;
        };
      };
    };
    # Shell 个性化
    settings = {
      paths.wallpaperDir = "~/Pictures/wallpapers";
      bar.status.showBattery = true;
      appearance.transparency.enabled = true;
    };
  };

  # ---------- 常用工具 ----------
  home.packages = with pkgs; [
    hyprland 
    xdg-desktop-portal-hyprland
    foot 
    fish 
    fastfetch
    btop 
    fuzzel
    wl-clipboard 
    cliphist 
    grim 
    slurp 
    swappy
  ];

  programs.fish.enable = true;
}
