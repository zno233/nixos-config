{
  flake.modules.homeManager.media-apps =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        ## Multimedia
        audacity
        gimp
        # imv # Image viewer for Wayland
        pix # Generic image viewer from Linux Mint
        # digikam # Image viewer for details
        # media-downloader
        obs-studio
        # soundwireserver
        # video-trimmer
        vlc

        fooyin # like fb2k
        #spotify

        (pkgs.mpv.override {
          scripts = [ pkgs.mpvScripts.mpris ];
        })
        mpv-handler
        splayer-next
        # kazumi # anime online
        tsukimi # emby
        # tauon                       #local music player
        # gapless
      ];
    };
}
