{ ... }:
{
  imports = [
    ./bat.nix                         # better cat command
    ./btop.nix                        # resouces monitor 
    ./cava.nix                        # audio visualizer
    #./caelestia.nix
    #./fish.nix
    ./fastfetch/fastfetch.nix         # fetch tool
    ./fzf.nix                         # fuzzy finder
    ./ghostty/ghostty.nix             # terminal
    ./gnome.nix                       # gnome apps
    ./gtk.nix                         # gtk theme
    ./hyprlock.nix
    ./kitty.nix                       # terminal
    ./micro.nix                       # nano replacement
    ./nemo.nix                        # file manager
    ./rofi/rofi.nix                   # launcher
    ./scripts/scripts.nix             # personal scripts
    ./superfile/superfile.nix         # terminal file manager
    ./swaylock.nix                    # lock screen
    ./swayosd.nix                     # brightness / volume wiget
    ./swaync/swaync.nix               # notification deamon
    ./vicinae/vicinae.nix             # launcher
    ./waybar                          # status bar
    ./waypaper.nix                    # GUI wallpaper picker
    ./wm                              # window manager
    ./xdg-mimes.nix                   # xdg config
    ./zsh                             # shell
  ];
}
