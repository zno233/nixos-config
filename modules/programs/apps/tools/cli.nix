{
  flake.modules.homeManager.cli =
    { pkgs, ... }:
    {
      # Configure common command-line tools and utilities
      home.packages = with pkgs; [
        ## Better core utils
        duf # Disk information
        # eza # ls replacement
        # fd # find replacement
        gping # ping with a graph
        gtrash # rm replacement, put deleted files in system trash
        hexyl # hex viewer
        man-pages # extra man pages
        ncdu # disk space
        ripgrep # grep replacement
        tldr # Command-line documentation viewer

        ## Tools / useful cli
        # aoc-cli # Advent of Code command-line tool
        # asciinema # Terminal session recorder
        # asciinema-agg # asciinema aggregator
        binsider # Inspect binaries from the comfort of your terminal
        bitwise # cli tool for bit / hex manipulation
        broot # tree files view
        # caligula # User-friendly, lightweight TUI for disk imaging
        hyperfine # benchmarking tool
        # pastel # cli to manipulate colors
        # swappy # snapshot editing tool
        tdf # cli pdf viewer
        tokei # project line counter
        # translate-shell # cli translator
        # woomer # CLI tool to control WoW eBook reader
        yt-dlp-light # youtube-dl fork
        brightnessctl # backlight controller
        graphviz # graph visualization software
        pciutils # PCI bus utilities

        ## TUI
        # epy # ebook reader
        # gtt # google translate TUI
        # programmer-calculator # Programmer's calculator
        # toipe # typing test in the terminal
        # ttyper # cli typing test

        ## Monitoring / fetch
        # htop # Interactive process viewer
        onefetch # fetch utility for git repo
        wavemon # monitoring for wireless network devices
        lm_sensors # Hardware health monitoring

        ## Fun / screensaver
        # asciiquarium-transparent # aquarium animation in terminal
        cbonsai # create bonsai tree in terminal
        cmatrix # matrix rain effect in terminal
        # countryfetch # fetch utility showing country flag and info
        cowsay # Display messages in cow speech bubbles
        # figlet # Create large letters from ordinary text
        fortune # Display random quotations
        # lavat # Lava lamp simulation
        # lolcat # Rainbow colorized output
        pipes # Pipes screen saver
        sl # Steam locomotive animation
        tty-clock # Digital clock in terminal

        ## Multimedia
        imv # Image viewer for Wayland
        # lowfi # Lo-fi music player

        ## Utilities
        entr # perform action when file change
        ffmpeg # Video/audio conversion tool
        file # Show file information
        jq # JSON processor
        # killall # Kill processes by name
        libnotify # Desktop notification library
        # mimeo # MIME type opener
        openssl # Cryptography toolkit
        pamixer # pulseaudio command line mixer
        playerctl # controller for media players
        poweralertd # Power alert daemon
        udiskie # Automounter for removable media
        # unzip # Extract zip archives
        wget # Network downloader
        xdg-utils # Desktop integration utilities
        # p7zip-rar # Archive utility with RAR support
        unar # Extract many archive formats
        pandoc # Universal document converter
        usbutils # USB device utilities

        android-tools # Android tools for command-line
      ];
    };
}
