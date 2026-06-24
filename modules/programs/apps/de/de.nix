{ inputs, ... }:
{
  flake.modules.homeManager.de = {
    imports = with inputs.self.modules.homeManager; [
      ### shared
      bat # better cat command
      btop # resouces monitor
      cava # audio visualizer
      fastfetch # fetch tool
      fzf # fuzzy finder
      ghostty # terminal
      gnome # gnome apps
      # gtk # gtk theme
      kitty # terminal
      nemo # file manager
      # superfile/superfile         # terminal file manager
      wm # window manager
      xdg-mimes # xdg config
      stylix # theme
      # wayscrollshot # A scrolling screenshot tool for Wayland write in Rust
      zsh # shell

      ### de without shell
      #hyprlock
      #rofi                 # launcher
      #wm/hyprland/scripts/scripts # personal scripts
      #swaylock                    # lock screen
      #swayosd                     # brightness / volume wiget
      #swaync              # notification deamon
      #vicinae           # launcher
      #waybar-niri                          # status bar
      #waypaper                    # GUI wallpaper picker

      ### using shell
      # noctalia
      inir

      # optinal
      #caelestia
      #fish
      #micro                       # nano replacement
    ];
  };
}
