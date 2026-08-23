{
  flake.modules.homeManager.ebook =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        calibre
        koodo-reader
        readest
      ];
    };
}
