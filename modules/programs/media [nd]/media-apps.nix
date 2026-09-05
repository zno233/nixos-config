{
  flake.modules.homeManager.media-apps =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        ## ── Image ────────────────────────────────────────────────────
        gimp # image editor
        pix # image viewer (Linux Mint)
        imv # image viewer (Wayland)
        # digikam # photo manager

        ## ── Video player ────────────────────────────────────────────
        (pkgs.mpv.override {
          scripts = [ pkgs.mpvScripts.mpris ];
        })
        mpv-handler # mpv URL handler
        vlc # media player
        # video-trimmer

        ## ── Audio player ────────────────────────────────────────────
        fooyin # foobar2k-like
        splayer-next # music player
        # spotify
        # tauon # local music player
        # gapless

        ## ── Streaming / Media service ───────────────────────────────
        tsukimi # Emby client
        # kazumi # anime streaming

        ## ── Recording / Editing ─────────────────────────────────────
        obs-studio # screen recording/streaming
        audacity # audio editor

        ## ── Misc ────────────────────────────────────────────────────
        # media-downloader
        # soundwireserver
      ];
    };
}
