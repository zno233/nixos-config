## Overview
### Noctalia-shell
<img width="2520" height="1680" alt="Screenshot from 2026-01-10 12-33-18" src="https://github.com/user-attachments/assets/0b28b5df-9936-4e93-a762-efed37c3e88e" />

### No shell
<img width="2520" height="1680" alt="Screenshot from 2025-12-19 21-16-32" src="https://github.com/user-attachments/assets/37ce7c1f-c7bb-4a6f-b8b9-e5738f9f06e7" />


---
## Project Tree
```
zno-config
├─ README.md
├─ flake-modules
│  └─ hosts.nix
├─ flake.lock
├─ flake.nix
├─ home
│  ├─ common
│  │  ├─ default.nix
│  │  └─ rime-user-overrides
│  │     ├─ default.nix
│  │     └─ rime-user-overrides
│  │        └─ default.custom.yaml
│  ├─ desktop
│  │  └─ default.nix
│  └─ laptop
│     └─ default.nix
├─ hosts
│  ├─ desktop
│  │  ├─ default.nix
│  │  └─ hardware-configuration.nix
│  ├─ laptop
│  │  ├─ default.nix
│  │  ├─ fileSystems.nix
│  │  ├─ hardware-configuration.nix
│  │  └─ hardware.nix
│  └─ vm
│     ├─ default.nix
│     └─ hardware-configuration.nix
├─ modules
│  ├─ home-manager
│  │  ├─ common
│  │  │  ├─ ai
│  │  │  │  ├─ default.nix
│  │  │  │  ├─ gemini-cli.nix
│  │  │  │  └─ ollama.nix
│  │  │  ├─ browsers
│  │  │  │  ├─ browsers.nix
│  │  │  │  ├─ default.nix
│  │  │  │  └─ zen.nix
│  │  │  ├─ default.nix
│  │  │  ├─ dev
│  │  │  │  ├─ default.nix
│  │  │  │  ├─ dev.nix
│  │  │  │  ├─ git.nix
│  │  │  │  ├─ lazygit.nix
│  │  │  │  └─ nvim
│  │  │  │     ├─ lazyvim
│  │  │  │     └─ nvim.nix
│  │  │  ├─ game
│  │  │  │  ├─ default.nix
│  │  │  │  └─ gaming.nix
│  │  │  ├─ media
│  │  │  │  ├─ audacious
│  │  │  │  │  ├─ audacious.nix
│  │  │  │  │  ├─ config
│  │  │  │  │  └─ eq.preset
│  │  │  │  ├─ default.nix
│  │  │  │  ├─ media.nix
│  │  │  │  └─ spotify.nix
│  │  │  ├─ note
│  │  │  │  ├─ default.nix
│  │  │  │  └─ obsidian.nix
│  │  │  ├─ office
│  │  │  │  ├─ default.nix
│  │  │  │  └─ office.nix
│  │  │  ├─ social
│  │  │  │  ├─ default.nix
│  │  │  │  ├─ discord.nix
│  │  │  │  └─ social.nix
│  │  │  └─ tools
│  │  │     ├─ aseprite
│  │  │     │  ├─ aseprite.nix
│  │  │     │  └─ themes
│  │  │     ├─ cli.nix
│  │  │     ├─ default.nix
│  │  │     ├─ glance
│  │  │     │  └─ glance.nix
│  │  │     ├─ nix-search
│  │  │     │  ├─ config.json
│  │  │     │  ├─ nix-search.nix
│  │  │     │  └─ nix-search.sh
│  │  │     ├─ nix.nix
│  │  │     ├─ p10k
│  │  │     │  ├─ .p10k.zsh
│  │  │     │  └─ p10k.nix
│  │  │     ├─ ssh.nix
│  │  │     └─ tools.nix
│  │  ├─ desktop
│  │  │  └─ default.nix
│  │  └─ laptop
│  │     ├─ de
│  │     │  ├─ bat.nix
│  │     │  ├─ btop.nix
│  │     │  ├─ caelestia.nix
│  │     │  ├─ cava.nix
│  │     │  ├─ default.nix
│  │     │  ├─ fastfetch
│  │     │  │  ├─ ascii
│  │     │  │  ├─ config.jsonc
│  │     │  │  ├─ fastfetch.nix
│  │     │  │  └─ png
│  │     │  ├─ fish.nix
│  │     │  ├─ fzf.nix
│  │     │  ├─ ghostty
│  │     │  │  ├─ ghostty.nix
│  │     │  │  └─ styles
│  │     │  ├─ gnome.nix
│  │     │  ├─ gtk.nix
│  │     │  ├─ hyprlock
│  │     │  │  ├─ .hyprlock
│  │     │  │  ├─ hyprlock.conf
│  │     │  │  ├─ hyprlock.nix
│  │     │  ├─ kitty.nix
│  │     │  ├─ micro.nix
│  │     │  ├─ nemo.nix
│  │     │  ├─ noctalia
│  │     │  │  ├─ .noctalia
│  │     │  │  └─ noctalia.nix
│  │     │  ├─ rofi
│  │     │  │  ├─ config.rasi
│  │     │  │  ├─ powermenu-theme.rasi
│  │     │  │  ├─ rofi.nix
│  │     │  │  └─ theme.rasi
│  │     │  ├─ superfile
│  │     │  │  ├─ config.toml
│  │     │  │  └─ superfile.nix
│  │     │  ├─ swaylock.nix
│  │     │  ├─ swaync
│  │     │  │  ├─ config.json
│  │     │  │  ├─ style.css
│  │     │  │  └─ swaync.nix
│  │     │  ├─ swayosd.nix
│  │     │  ├─ vicinae
│  │     │  │  ├─ gruvbox-dark-hard.json
│  │     │  │  ├─ vicinae.json
│  │     │  │  └─ vicinae.nix
│  │     │  ├─ waybar
│  │     │  │  ├─ config.jsonc
│  │     │  │  ├─ default.nix
│  │     │  │  ├─ scripts
│  │     │  │  ├─ style.css
│  │     │  │  └─ waybar-niri.nix
│  │     │  ├─ waypaper.nix
│  │     │  ├─ wm
│  │     │  │  ├─ default.nix
│  │     │  │  ├─ hyprland
│  │     │  │  │  ├─ binds.nix
│  │     │  │  │  ├─ default.nix
│  │     │  │  │  ├─ exec-once.nix
│  │     │  │  │  ├─ hyprland.nix
│  │     │  │  │  ├─ monitors.nix
│  │     │  │  │  ├─ scripts
│  │     │  │  │  │  ├─ scripts
│  │     │  │  │  │  └─ scripts.nix
│  │     │  │  │  ├─ settings.nix
│  │     │  │  │  ├─ variables.nix
│  │     │  │  │  └─ windowrules.nix
│  │     │  │  └─ niri
│  │     │  │     ├─ config.kdl
│  │     │  │     └─ default.nix
│  │     │  ├─ xdg-mimes.nix
│  │     │  └─ zsh
│  │     │     ├─ default.nix
│  │     │     ├─ zsh.nix
│  │     │     ├─ zsh_alias.nix
│  │     │     └─ zsh_keybinds.nix
│  │     └─ default.nix
│  └─ system
│     ├─ common
│     └─ nixos
│        ├─ core
│        │  ├─ bluetooth.nix
│        │  ├─ default.nix
│        │  ├─ fcitx5.nix
│        │  ├─ font.nix
│        │  ├─ graphics.nix
│        │  ├─ greetd.nix
│        │  ├─ network.nix
│        │  ├─ nh.nix
│        │  ├─ nixpkgs.nix
│        │  ├─ pipewire.nix
│        │  ├─ security.nix
│        │  ├─ services.nix
│        │  ├─ system.nix
│        │  ├─ systemd-boot.nix
│        │  ├─ user.nix
│        │  ├─ virtualization.nix
│        │  ├─ xdg.nix
│        │  └─ xserver.nix
│        ├─ default.nix
│        └─ optional
│           ├─ appImage.nix
│           ├─ dae.nix
│           ├─ default.nix
│           ├─ distrobox.nix
│           ├─ docker.nix
│           ├─ flatpak.nix
│           ├─ fprintd.nix
│           ├─ grub-boot.nix
│           ├─ program.nix
│           ├─ scx.nix
│           ├─ sddm.nix
│           ├─ steam.nix
│           ├─ systemd-oomd.nix
│           ├─ tomcat.nix
│           └─ zram.nix
├─ pkgs
│  ├─ 2048
│  │  └─ default.nix
│  ├─ default.nix
│  └─ maple-mono
│     └─ default.nix
└─ wallpapers
   ├─ otherWallpaper
   │  ├─ gruvbox
   │  ├─ nixos
   │  └─ others
   └─ wallpaper.png

```

## Credits
Other dotfiles that I ~~copied~~ learned from:
 - [ryan4yin/nix-config](https://github.com/ryan4yin/nix-config)
 - [Frost-Phoenix/nixos-config](https://github.com/Frost-Phoenix/nixos-config)
