{
  lib,
  feishu,
  buildEnv,
  mkNixPak,
  mkAppWrapper,
  makeDesktopItem,
  ...
}:
let
  appId = "cn.feishu.Feishu";
  wrapped = mkNixPak {
    config =
      { ... }:
      {
        imports = [
          ./modules/desktop-base.nix
          ./modules/network.nix
        ];
        app.package = mkAppWrapper feishu {
          binPath = "opt/bytedance/feishu/feishu";
          extraWrapperArgs = [
            "--add-flags"
            "--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true --wayland-text-input-version=3"
          ];
        };
        flatpak = {
          appId = appId;
        };
        portalGroups = {
          fileChooser = true;
          openUri = true;
          notifications = true;
          inputMethod = true;
          # Meetings: camera and screen sharing go through the portals.
          screenCast = true;
          camera = true;
          print = true;
        };
        desktopIntegration = {
          notifications = true;
          tray = true;
        };
        bubblewrap = {
          bind.ro = [ "/etc/passwd" ];
          env = {
            GTK_IM_MODULE = "fcitx";
            QT_IM_MODULE = "fcitx";
            XMODIFIERS = "@im=fcitx";
          };
        };
        dbus = {
          policies = {
            "org.freedesktop.secrets" = "talk";
            "org.gnome.keyring" = "talk";
            "org.gnome.ScreenSaver" = "talk";
            "com.canonical.AppMenu.Registrar" = "talk";
            "com.canonical.indicator.application" = "talk";
            "org.ayatana.indicator.application" = "talk";
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
      desktopName = "Feishu";
      genericName = "Feishu";
      comment = "Feishu is an all-in-one platform that integrates instant communication, calendar, video meeting, collaborative documents, workplace, and various features. Feishu aims to make your work more enjoyable while achieving better organizational results.";
      exec = "${exePath} %U";
      startupNotify = true;
      terminal = false;
      icon = "${feishu}/share/icons/hicolor/256x256/apps/bytedance-feishu.png";
      type = "Application";
      categories = [ "Office" ];
      mimeTypes = [
        "message/rfc822"
        "x-scheme-handler/feishu"
        "x-scheme-handler/feishu-open"
        "x-scheme-handler/lark"
        "x-scheme-handler/x-feishu"
      ];
      extraConfig = {
        X-Flatpak = appId;
        X-KDE-DBUS-Restricted-Interfaces = "org.kde.kwin.Screenshot,org.kde.KWin.ScreenShot2";
      };
    })
  ];
}
