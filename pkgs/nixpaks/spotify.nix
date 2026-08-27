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
          ./modules/gui-base.nix
          ./modules/network.nix
          ./modules/common.nix
        ];
        app.package = spotify;
        flatpak = {
          appId = appId;
        };
        dbus = {
          enable = true;
          policies = {
            "org.gnome.SettingsDaemon.MediaKeys" = "talk";
            "org.gnome.SessionManager" = "talk";
            "org.kde.StatusNotifierWatcher" = "talk";
            "org.mpris.MediaPlayer2.spotify" = "own";
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
