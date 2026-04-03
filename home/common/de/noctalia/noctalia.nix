{
  config,
  inputs,
  pkgs,
  ...
}:
let
  noctaliaConfig = "${config.home.homeDirectory}/zno-config/home/common/de/noctalia/.noctalia";
in
{
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
}
