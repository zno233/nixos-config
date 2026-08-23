{
  flake.modules.homeManager.tool-apps =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        ## Utility
        dconf-editor
        gnome-disk-utility
        mission-center # GUI resources monitor
        zenity
        font-manager
        localsend
        nwg-look
        bleachbit # System cleaner
        peazip # Archive extractor
        qalculate-qt

        ## Torrent
        qbittorrent-enhanced # bt

        ## Level editor
        # ldtk
        # tiled

        ## Others
        # maa-cli
        # windterm
        # snipaste
      ];
    };
}
