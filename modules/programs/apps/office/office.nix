{
  flake.modules.homeManager.office =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        wpsoffice-cn
        libreoffice
        # onlyoffice-desktopeditors
      ];
    };
}
