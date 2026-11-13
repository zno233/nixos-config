{
  lib,
  spotify,
  buildEnv,
  mkNixPak,
  makeDesktopItem,
  ...
}:
let
  appId = "com.spotify.Client";
  wrapped = mkNixPak {
    config =
      { ... }:
      {
        imports = [
          ./modules/desktop-base.nix
          ./modules/network.nix
        ];
        app.package = spotify;
        flatpak = {
          appId = appId;
        };
        # Playback controls and the tray icon are handled by
        # `desktopIntegration`; login links open through the URI portal.
        portalGroups = {
          fileChooser = true;
          openUri = true;
          notifications = true;
          inputMethod = true;
        };
        desktopIntegration = {
          notifications = true;
          tray = true;
          mpris = true;
        };
        bubblewrap = {
          bind.ro = [ "/etc/passwd" ];
          env = {
            GTK_IM_MODULE = "fcitx";
            QT_IM_MODULE = "fcitx";
            XMODIFIERS = "@im=fcitx";
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
      desktopName = "Spotify";
      comment = "Online music streaming service";
      tryExec = "${exePath}";
      exec = "${exePath} %U";
      icon = appId;
      terminal = false;
      type = "Application";
      categories = [
        "Audio"
        "Music"
        "Player"
        "AudioVideo"
      ];
      mimeTypes = [ "x-scheme-handler/spotify" ];
      startupWMClass = "spotify";
      extraConfig = {
        X-Flatpak = appId;
        X-GNOME-UsesNotifications = "true";
      };
    })
  ];
}
