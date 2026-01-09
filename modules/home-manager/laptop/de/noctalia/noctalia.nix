{
  config,
  inputs,
  pkgs,
  ...
}: {
  imports = [
      inputs.noctalia.homeModules.default
    ];

  home.packages = [
    pkgs.qt6Packages.qt6ct # for icon theme
    pkgs.app2unit # Launch Desktop Entries (or arbitrary commands) as Systemd user units
  ];

  programs.noctalia-shell = {
    enable = true;
  };

  xdg.configFile."noctalia" = {
    source = config.lib.file.mkOutOfStoreSymlink
      "/home/zno/zno-config/modules/home-manager/laptop/de/noctalia/.noctalia";
    force = true;
  };
}
