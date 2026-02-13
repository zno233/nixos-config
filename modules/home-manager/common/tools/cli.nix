{ pkgs, ... }:
{
  home.packages = with pkgs; [
    ## Better core utils
    duf                               # disk information
    eza                               # ls replacement
    fd                                # find replacement
    gping                             # ping with a graph
    gtrash                            # rm replacement, put deleted files in system trash
    hexyl                             # hex viewer
    man-pages                         # extra man pages
    ncdu                              # disk space
    ripgrep                           # grep replacement
    tldr

    ## Tools / useful cli
    aoc-cli                           # Advent of Code command-line tool
    asciinema
    asciinema-agg
    binsider
    bitwise                           # cli tool for bit / hex manipulation
    broot                             # tree files view
    caligula                          # User-friendly, lightweight TUI for disk imaging
    hyperfine                         # benchmarking tool
    pastel                            # cli to manipulate colors
    swappy                            # snapshot editing tool
    tdf                               # cli pdf viewer
    tokei                             # project line counter
    translate-shell                   # cli translator
    woomer                            # CLI tool to control WoW eBook reader
    yt-dlp-light                      # youtube-dl fork       
    light                             # backlight controller
    graphviz                          # graph visualization software

    ## TUI
    epy                               # ebook reader
    gtt                               # google translate TUI
    programmer-calculator
    toipe                             # typing test in the terminal
    ttyper                            # cli typing test

    ## Monitoring / fetch
    htop
    onefetch                          # fetch utility for git repo
    wavemon                           # monitoring for wireless network devices
    lm_sensors
    
    ## Fun / screensaver
    asciiquarium-transparent         # aquarium animation in terminal
    cbonsai                          # create bonsai tree in terminal
    cmatrix                          # matrix rain effect in terminal
    countryfetch                    # fetch utility showing country flag and info      
    cowsay
    figlet
    fortune
    lavat
    lolcat
    pipes
    sl
    tty-clock

    ## Multimedia
    imv
    lowfi
    

    ## Utilities
    entr                              # perform action when file change
    ffmpeg
    file                              # Show file information
    jq                                # JSON processor
    killall
    libnotify
    mimeo
    openssl
    pamixer                           # pulseaudio command line mixer
    playerctl                         # controller for media players
    poweralertd
    udiskie                           # Automounter for removable media
    unzip
    wget
    wl-clipboard                      # clipboard utils for wayland (wl-copy, wl-paste)
    xdg-utils
    p7zip-rar
    unar                              # Extract many archive formats
    

    winetricks
    wineWow64Packages.waylandFull
  ];
}
