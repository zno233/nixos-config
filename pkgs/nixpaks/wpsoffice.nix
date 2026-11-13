{
  lib,
  pkgs,
  wpsoffice-cn,
  buildEnv,
  mkNixPak,
  mkAppWrapper,
  makeDesktopItem,
  ...
}:
let
  appId = "cn.wps.app";
  wrapped = mkNixPak {
    config =
      { sloth, ... }:
      {
        imports = [
          ./modules/desktop-base.nix
          ./modules/network.nix
        ];
        app.package = mkAppWrapper wpsoffice-cn {
          binPath = "bin/wps";
          prefixPathes = with pkgs; [
            coreutils
            glib # provides "gsettings"
            gawk
            gnugrep
            gnused
          ];
        };
        flatpak = {
          inherit appId;
        };
        portalGroups = {
          fileChooser = true;
          openUri = true;
          notifications = true;
          inputMethod = true;
          print = true;
        };
        desktopIntegration = {
          notifications = true;
          tray = true;
        };
        bubblewrap = {
          sockets.wayland = lib.mkForce false;
          shareIpc = true;
          tmpfs = [ "/var/tmp" ];
          bind.ro = [
            "/etc/machine-id"
            "/etc/passwd"
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
            XDG_SESSION_TYPE = lib.mkForce "x11";
            GTK_IM_MODULE = "fcitx";
            QT_IM_MODULE = "fcitx";
            XMODIFIERS = "@im=fcitx";
            QT_FONT_DPI = "148";
            QT_QPA_PLATFORM = "xcb";
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
      genericName = "Office Suite";
      comment = "WPS Office - Word, Spreadsheet, Presentation";
      exec = "${exePath} %U";
      startupNotify = false;
      terminal = false;
      icon = "${wpsoffice-cn}/share/icons/hicolor/scalable/apps/wps-office2023-wpsmain.svg";
      type = "Application";
      categories = [
        "Office"
        "WordProcessor"
        "Qt"
      ];
      mimeTypes = [
        "application/msword"
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
        "application/vnd.ms-excel"
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        "application/vnd.ms-powerpoint"
        "application/vnd.openxmlformats-officedocument.presentationml.presentation"
        "application/pdf"
        "application/vnd.oasis.opendocument.text"
        "application/vnd.oasis.opendocument.spreadsheet"
        "application/vnd.oasis.opendocument.presentation"
        "text/plain"
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
