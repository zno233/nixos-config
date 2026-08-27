{
  flake.modules.homeManager.office =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        # 使用 nixpak 沙箱包装版本（含 fcitx 环境变量、bubblewrap 沙箱）
        nixpaks.wpsoffice
        libreoffice
        # onlyoffice-desktopeditors
      ];
    };
}
