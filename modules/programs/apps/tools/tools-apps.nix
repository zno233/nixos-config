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

        ## Level editor
        # ldtk
        # tiled

        gnome-calculator

        qbittorrent-enhanced # bt
        #windterm
        calibre
        snipaste
        font-manager
        localsend
        # maa-cli

        nwg-look
        bleachbit # System cleaner
      ];
    };
}
