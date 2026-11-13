{
  lib,
  wemeet,
  buildEnv,
  mkAppWrapper,
  mkNixPak,
  makeDesktopItem,
  ...
}:
let
  appId = "com.tencent.wemeet";
  wrapped = mkNixPak {
    config =
      { ... }:
      {
        imports = [
          ./modules/desktop-base.nix
          ./modules/network.nix
        ];
        app.package = mkAppWrapper wemeet { binPath = "bin/wemeet-xwayland"; };
        flatpak = { inherit appId; };
        portalGroups = {
          fileChooser = true;
          openUri = true;
          notifications = true;
          inputMethod = true;
          screenCast = true;
          camera = true;
        };
        desktopIntegration = {
          notifications = true;
          tray = true;
        };
        bubblewrap = {
          sockets.wayland = lib.mkForce false;
          env = {
            XDG_SESSION_TYPE = lib.mkForce "x11";
            GTK_IM_MODULE = "fcitx";
            QT_IM_MODULE = "fcitx";
            XMODIFIERS = "@im=fcitx";
          };
          bind.ro = [ "/etc/passwd" ];
          # Webcam access for meetings.
          bind.dev = map (id: "/dev/video${toString id}") (lib.range 0 9);
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
