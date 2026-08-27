{
  flake.modules.homeManager.social-apps =
    { pkgs, ... }:

    {
      home.packages = with pkgs; [
        # global
        telegram-desktop
        element-desktop
        # cn — 使用 nixpak 沙箱包装版本
        nixpaks.qq
        nixpaks.wechat
      ];
    };
}
