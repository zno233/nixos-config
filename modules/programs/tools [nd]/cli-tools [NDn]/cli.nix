{
  flake.modules.homeManager.cli =
    {
      pkgs,
      ...
    }:
    {
      home.packages = with pkgs; [
        ## ── Core utils replacements ──────────────────────────────────
        # eza # ls replacement
        # fd # find replacement
        ripgrep # grep replacement
        gtrash # rm → trash
        duf # df replacement
        ncdu # du replacement (TUI)
        hexyl # xxd replacement (hex viewer)

        ## ── File / Archive ──────────────────────────────────────────
        file # file type detection
        unar # multi-format archive extractor
        # unzip
        # p7zip-rar
        broot # tree view + file manager (TUI)

        ## ── Text processing ─────────────────────────────────────────
        jq # JSON processor
        jaq # jq clone (Rust, faster)
        pandoc # universal document converter
        # pastel # color manipulation

        ## ── Network / Download ──────────────────────────────────────
        wget # downloader
        gping # ping with graph
        yt-dlp-light # youtube-dl fork

        ## ── System / Hardware ───────────────────────────────────────
        brightnessctl # backlight control
        pciutils # lspci
        usbutils # lsusb
        lm_sensors # hardware sensors
        wavemon # wireless monitoring
        # killall
        # poweralertd # low battery alerts (Noctalia handles this)

        ## ── Multimedia ──────────────────────────────────────────────
        ffmpeg # video/audio conversion
        pamixer # PulseAudio mixer (CLI)
        playerctl # media player controller
        # lowfi # lo-fi music player

        ## ── Development ─────────────────────────────────────────────
        hyperfine # benchmarking
        tokei # line counter
        binsider # binary inspector
        bitwise # bit/hex manipulation
        openssl # crypto toolkit
        graphviz # graph visualization
        entr # file watcher → execute

        ## ── Desktop integration ─────────────────────────────────────
        libnotify # notify-send
        xdg-utils # xdg-open etc.
        udiskie # auto-mount removable media

        ## ── Documentation ───────────────────────────────────────────
        tldr # simplified man pages
        man-pages # extra man pages

        ## ── TUI apps ────────────────────────────────────────────────
        # tdf # PDF viewer (TUI)
        # epy # ebook reader
        # gtt # Google Translate TUI
        # programmer-calculator
        # toipe # typing test
        # ttyper # typing test

        ## ── Monitoring / Fetch ──────────────────────────────────────
        onefetch # git repo fetch
        # htop # process viewer (Noctalia/btop handles this)

        ## ── Fun / Screensaver ───────────────────────────────────────
        cmatrix # Matrix rain
        pipes # pipe screensaver
        cbonsai # bonsai tree
        tty-clock # digital clock
        sl # steam locomotive
        cowsay # cow speech bubble
        fortune # random quotes
        # asciiquarium-transparent # aquarium
        # countryfetch # fetch with flag
        # figlet # large text
        # lavat # lava lamp
        # lolcat # rainbow output

        ## ── Misc ────────────────────────────────────────────────────
        android-tools # adb, fastboot
      ];
    };
}
