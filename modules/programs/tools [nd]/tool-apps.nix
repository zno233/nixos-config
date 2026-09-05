{
  flake.modules.homeManager.tool-apps =
    {
      pkgs,
      ...
    }:
    {
      home.packages = with pkgs; [
        ## ── System ───────────────────────────────────────────────────
        dconf-editor # dconf GUI
        mission-center # system monitor (GUI)
        bleachbit # system cleaner
        gnome-disk-utility # disk management

        ## ── File / Archive ──────────────────────────────────────────
        peazip # archive extractor

        ## ── Desktop ─────────────────────────────────────────────────
        nwg-look # GTK theme selector
        font-manager # font management
        zenity # dialog boxes
        localsend # local file sharing

        ## ── Calculator ──────────────────────────────────────────────
        qalculate-qt # scientific calculator

        ## ── Torrent ─────────────────────────────────────────────────
        qbittorrent-enhanced # BitTorrent client

        ## ── Development ─────────────────────────────────────────────
        # ldtk # level editor
        # tiled # tile map editor

        ## ── Misc ────────────────────────────────────────────────────
        # maa-cli # MaaAssistantArknights
        # windterm # terminal emulator
        # snipaste # screenshot tool
      ];
    };
}
