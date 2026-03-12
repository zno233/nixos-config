{ ... }:
{
  imports = [
    ### shared
    ./bat.nix # better cat command
    ./btop.nix # resouces monitor
    ./cava.nix # audio visualizer
    ./fastfetch/fastfetch.nix # fetch tool
    ./fzf.nix # fuzzy finder
    ./ghostty/ghostty.nix # terminal
    ./gnome.nix # gnome apps
    ./gtk.nix # gtk theme
    ./kitty.nix # terminal
    ./nemo.nix # file manager
    # ./superfile/superfile.nix         # terminal file manager
    ./wm # window manager
    ./xdg-mimes.nix # xdg config
    ./zsh # shell

    ### de without shell
    #./hyprlock/hyprlock.nix
    #./rofi/rofi.nix                   # launcher
    #../../../../scripts/scripts.nix   # personal scripts
    #./swaylock.nix                    # lock screen
    #./swayosd.nix                     # brightness / volume wiget
    #./swaync/swaync.nix               # notification deamon
    #./vicinae/vicinae.nix             # launcher
    #./waybar                          # status bar
    #./waypaper.nix                    # GUI wallpaper picker

    ### using shell
    ./noctalia/noctalia.nix

    # optinal
    #./caelestia.nix
    #./fish.nix
    #./micro.nix                       # nano replacement
  ];
}
