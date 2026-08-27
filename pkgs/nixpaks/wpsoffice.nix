{
  lib,
  pkgs,
  wpsoffice-cn,
  buildEnv,
  mkNixPak,
  mkAppWrapper,
  makeDesktopItem,
}:
let
  appId = "cn.wps.app";
  wrapped = mkNixPak {
    config =
      { sloth, ... }:
      {
        imports = [
          ./modules/gui-base.nix
          ./modules/network.nix
          ./modules/common.nix
        ];
        app.package = mkAppWrapper wpsoffice-cn {
          binPath = "bin/wps";
          prefixPathes = with pkgs; [
            coreutils
            glib # provides "gsettings"
          ];
        };
        flatpak = {
          inherit appId;
        };
        dbus.enable = true;
        bubblewrap = {
          sockets = {
            wayland = lib.mkForce false;
            x11 = true;
          };
          shareIpc = true;
          tmpfs = [ "/var/tmp" ];
          bind.ro = [
            "/etc/passwd"
            "/etc/machine-id"
          ];
          bind.rw = with sloth; [
            [
              (mkdir (concat' appDir "/kingsoft"))
              (concat' homeDir "/.kingsoft")
            ]
            xdgDownloadDir
            xdgDocumentsDir
            xdgPicturesDir
            xdgVideosDir
          ];
          env = {
            GTK_IM_MODULE = "fcitx";
            QT_IM_MODULE = "fcitx";
            XMODIFIERS = "@im=fcitx";
            QT_FONT_DPI = "148";
          };
        };
      };
  };
  exePath = lib.getExe wrapped.config.script;
in
buildEnv {
  inherit (wrapped.config.script) name meta passthru;
  paths = [
    wrapped.config.script
    (makeDesktopItem {
      name = appId;
      desktopName = "WPS Office";
      genericName = "WPS";
      comment = "Use WPS Writer to office work.";
      exec = "${exePath} %f";
      startupNotify = false;
      terminal = false;
      icon = "${wpsoffice-cn}/share/icons/hicolor/scalable/apps/wps-office2023-wpsmain.svg";
      type = "Application";
      categories = [
        "Office"
        "WordProcessor"
        "Qt"
      ];
      startupWMClass = "wpsoffice";
      extraConfig = {
        X-Flatpak = appId;
        X-DBUS-ServiceName = "";
        X-DBUS-StartupType = "";
        X-KDE-SubstituteUID = "false";
        X-KDE-Username = "";
        InitialPreference = "3";
      };
    })
  ];
}
