{
  lib,
  wemeet,
  buildEnv,
  mkAppWrapper,
  mkNixPak,
  makeDesktopItem,
}:
let
  appId = "com.tencent.wemeet";
  wrapped = mkNixPak {
    config =
      { ... }:
      {
        imports = [
          ./modules/gui-base.nix
          ./modules/network.nix
          ./modules/common.nix
        ];
        app.package = mkAppWrapper wemeet { binPath = "bin/wemeet-xwayland"; };
        flatpak = { inherit appId; };
        bubblewrap = {
          sockets = {
            wayland = lib.mkForce false;
            x11 = true;
          };
        };
        dbus.policies = {
          "org.gnome.Shell.Screencast" = "talk";
          "org.freedesktop.Notifications" = "talk";
          "org.kde.StatusNotifierWatcher" = "talk";
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
      desktopName = "WemeetApp";
      genericName = "Wemeet";
      comment = "A cloud-based HD conferencing product leveraging Tencent's 20+ years of experience in audiovisual communications";
      exec = "${exePath} %u";
      terminal = false;
      icon = "${wemeet}/share/icons/hicolor/scalable/apps/wemeet.svg";
      type = "Application";
      categories = [ "Office" ];
      keywords = [
        "wemeet"
        "tencent"
        "meeting"
      ];
      mimeTypes = [ "x-scheme-handler/wemeet" ];
      extraConfig = {
        X-Flatpak = appId;
      };
    })
  ];
}
