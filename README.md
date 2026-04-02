## Overview
### Noctalia-shell
<img width="2520" height="1680" alt="Screenshot from 2026-01-10 12-33-18" src="https://github.com/user-attachments/assets/0b28b5df-9936-4e93-a762-efed37c3e88e" />

### Waybar
<img width="2520" height="1680" alt="Screenshot from 2025-12-19 21-16-32" src="https://github.com/user-attachments/assets/37ce7c1f-c7bb-4a6f-b8b9-e5738f9f06e7" />

---
## System Components & Applications

| Component | Software |
| --- | :---: |
| **Window Manager**          | [niri][niri] |
| **Bar**                     | [noctalia-shell][noctalia-shell] |
| **Terminal Emulator**       | [Kitty][Kitty] |
| **Shell**                   | [zsh][zsh] + [powerlevel10k][powerlevel10k] |
| **Input Method**            | [fcitx5][fcitx5] + [rime_wanxiang][rime_wanxiang] |
| **Text Editor**             | [VSCode][VSCode] + [lazyvim][lazyvim] |
| **network management tool** | [NetworkManager][NetworkManager] + [network-manager-applet][network-manager-applet] |
| **System resource monitor** | [Btop][Btop] |
| **File Manager**            | [nemo][nemo] |
| **Fonts**                   | [LXGW WenKai][LXGW WenKai] + [Maple Mono][Maple Mono]|
| **Color Scheme**            | [Gruvbox Dark Hard][Gruvbox] |
| **GTK theme**               | [Colloid gtk theme][Colloid gtk theme] |
| **Cursor**                  | [Bibata-Modern-Ice][Bibata-Modern-Ice] |
| **Icons**                   | [Papirus-Dark][Papirus-Dark] |
| **Image Viewer**            | [imv][imv] |
| **Media Player**            | [mpv][mpv] |
| **Music Player**            | [fooyin][fooyin] + [Splayer][Splayer] + [spicetify-nix][spicetify-nix] |
| **Screen Recording**        | [OBS][OBS] |

---
## Project Tree
```
zno-config
├─ LICENSE
├─ README.md
├─ flake.lock
├─ flake.nix
├─ home
│  ├─ common
│  │  ├─ ai
│  │  │  ├─ default.nix
│  │  │  ├─ gemini-cli.nix
│  │  │  └─ ollama.nix
│  │  ├─ browsers
│  │  │  ├─ browsers.nix
│  │  │  ├─ default.nix
│  │  │  └─ zen.nix
│  │  ├─ de
│  │  │  ├─ bat.nix
│  │  │  ├─ btop.nix
│  │  │  ├─ caelestia.nix
│  │  │  ├─ cava.nix
│  │  │  ├─ default.nix
│  │  │  ├─ fastfetch
│  │  │  │  ├─ ascii
│  │  │  │  ├─ config.jsonc
│  │  │  │  ├─ fastfetch.nix
│  │  │  │  └─ png
│  │  │  ├─ fish.nix
│  │  │  ├─ fzf.nix
│  │  │  ├─ ghostty
│  │  │  │  ├─ ghostty.nix
│  │  │  │  └─ styles
│  │  │  ├─ gnome.nix
│  │  │  ├─ gtk.nix
│  │  │  ├─ hyprlock
│  │  │  │  ├─ .hyprlock
│  │  │  │  ├─ hyprlock.conf
│  │  │  │  ├─ hyprlock.nix
│  │  │  ├─ kitty.nix
│  │  │  ├─ micro.nix
│  │  │  ├─ nemo.nix
│  │  │  ├─ noctalia
│  │  │  │  └─ noctalia.nix
│  │  │  ├─ rofi
│  │  │  │  ├─ config.rasi
│  │  │  │  ├─ powermenu-theme.rasi
│  │  │  │  ├─ rofi.nix
│  │  │  │  └─ theme.rasi
│  │  │  ├─ superfile
│  │  │  │  ├─ config.toml
│  │  │  │  └─ superfile.nix
│  │  │  ├─ swaylock.nix
│  │  │  ├─ swaync
│  │  │  │  ├─ config.json
│  │  │  │  ├─ style.css
│  │  │  │  └─ swaync.nix
│  │  │  ├─ swayosd.nix
│  │  │  ├─ vicinae
│  │  │  │  ├─ gruvbox-dark-hard.json
│  │  │  │  ├─ vicinae.json
│  │  │  │  └─ vicinae.nix
│  │  │  ├─ waybar
│  │  │  │  ├─ config.jsonc
│  │  │  │  ├─ default.nix
│  │  │  │  ├─ scripts
│  │  │  │  ├─ style.css
│  │  │  │  └─ waybar-niri.nix
│  │  │  ├─ waypaper.nix
│  │  │  ├─ wm
│  │  │  │  ├─ default.nix
│  │  │  │  ├─ hyprland
│  │  │  │  │  ├─ binds.nix
│  │  │  │  │  ├─ default.nix
│  │  │  │  │  ├─ exec-once.nix
│  │  │  │  │  ├─ hyprland.nix
│  │  │  │  │  ├─ monitors.nix
│  │  │  │  │  ├─ scripts
│  │  │  │  │  ├─ settings.nix
│  │  │  │  │  ├─ variables.nix
│  │  │  │  │  └─ windowrules.nix
│  │  │  │  └─ niri
│  │  │  │     ├─ config.kdl
│  │  │  │     └─ default.nix
│  │  │  ├─ xdg-mimes.nix
│  │  │  └─ zsh
│  │  │     ├─ default.nix
│  │  │     ├─ zsh.nix
│  │  │     ├─ zsh_alias.nix
│  │  │     └─ zsh_keybinds.nix
│  │  ├─ default.nix
│  │  ├─ dev
│  │  │  ├─ default.nix
│  │  │  ├─ dev.nix
│  │  │  ├─ git.nix
│  │  │  ├─ lazygit.nix
│  │  │  └─ nvim
│  │  │     └─ nvim.nix
│  │  ├─ game
│  │  │  ├─ default.nix
│  │  │  └─ gaming.nix
│  │  ├─ media
│  │  │  ├─ audacious
│  │  │  │  ├─ audacious.nix
│  │  │  │  ├─ config
│  │  │  │  └─ eq.preset
│  │  │  ├─ default.nix
│  │  │  ├─ media.nix
│  │  │  └─ spotify.nix
│  │  ├─ note
│  │  │  ├─ default.nix
│  │  │  └─ obsidian.nix
│  │  ├─ office
│  │  │  ├─ default.nix
│  │  │  └─ office.nix
│  │  ├─ others
│  │  │  ├─ default.nix
│  │  │  └─ rime-user-overrides
│  │  │     ├─ default.nix
│  │  │     └─ rime-user-overrides
│  │  │        └─ default.custom.yaml
│  │  ├─ scripts
│  │  │  ├─ default.nix
│  │  │  └─ scripts
│  │  ├─ social
│  │  │  ├─ default.nix
│  │  │  ├─ discord.nix
│  │  │  └─ social.nix
│  │  └─ tools
│  │     ├─ aseprite
│  │     │  ├─ aseprite.nix
│  │     │  └─ themes
│  │     ├─ cli.nix
│  │     ├─ default.nix
│  │     ├─ glance
│  │     │  └─ glance.nix
│  │     ├─ nix-search
│  │     │  ├─ config.json
│  │     │  ├─ nix-search.nix
│  │     │  └─ nix-search.sh
│  │     ├─ nix.nix
│  │     ├─ p10k
│  │     │  ├─ .p10k.zsh
│  │     │  └─ p10k.nix
│  │     ├─ ssh.nix
│  │     └─ tools.nix
│  └─ hosts
│     ├─ desktop
│     └─ laptop
│        └─ default.nix
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
│  ├─ common
│  └─ nixos
│     ├─ core
│     │  ├─ bluetooth.nix
│     │  ├─ default.nix
│     │  ├─ fcitx5.nix
│     │  ├─ font.nix
│     │  ├─ graphics.nix
│     │  ├─ greetd.nix
│     │  ├─ network.nix
│     │  ├─ nh.nix
│     │  ├─ nixpkgs.nix
│     │  ├─ pipewire.nix
│     │  ├─ security.nix
│     │  ├─ services.nix
│     │  ├─ system.nix
│     │  ├─ systemd-boot.nix
│     │  ├─ user.nix
│     │  ├─ virtualization.nix
│     │  ├─ xdg.nix
│     │  └─ xserver.nix
│     ├─ default.nix
│     └─ optional
│        ├─ appImage.nix
│        ├─ aria2.nix
│        ├─ dae.nix
│        ├─ default.nix
│        ├─ distrobox.nix
│        ├─ docker.nix
│        ├─ flatpak.nix
│        ├─ fprintd.nix
│        ├─ grub-boot.nix
│        ├─ program.nix
│        ├─ scx.nix
│        ├─ sddm.nix
│        ├─ steam.nix
│        ├─ systemd-oomd.nix
│        ├─ tomcat.nix
│        └─ zram.nix
├─ outputs
│  ├─ default.nix
│  ├─ desktop
│  ├─ laptop
│  │  └─ default.nix
│  └─ vm
├─ pkgs
│  ├─ 2048
│  │  └─ default.nix
│  ├─ default.nix
│  └─ maple-mono
│     └─ default.nix
└─ wallpapers
   ├─ otherWallpaper
   │  ├─ nixos
   │  └─ others
   └─ wallpaper.png

```

---
## Credits
Other dotfiles that I ~~copied~~ learned from:
 - [ryan4yin/nix-config](https://github.com/ryan4yin/nix-config)
 - [Frost-Phoenix/nixos-config](https://github.com/Frost-Phoenix/nixos-config)


<!-- Links -->

[niri]: https://github.com/niri-wm/niri
[noctalia-shell]: https://github.com/noctalia-dev/noctalia-shell
[Kitty]: https://swaywm.org/kitty/
[powerlevel10k]: https://github.com/romkatv/powerlevel10k
[Btop]: https://github.com/aristocratos/btop
[nemo]: https://github.com/linuxmint/nemo/
[zsh]: https://ohmyz.sh/
[fcitx5]: https://github.com/fcitx/fcitx5
[rime_wanxiang]: https://github.com/amzxyz/rime_wanxiang
[mpv]: https://github.com/mpv-player/mpv
[fooyin]: https://github.com/fooyin/fooyin
[Splayer]: https://github.com/imsyy/SPlayer
[spicetify-nix]: https://github.com/Gerg-L/spicetify-nix
[VSCode]: https://github.com/microsoft/vscode
[Lazyvim]: https://github.com/LazyVim/LazyVim
[imv]: https://sr.ht/~exec64/imv/
[Maple Mono]: https://github.com/subframe7536/maple-font
[LXGW WenKai]: https://github.com/lxgw/LxgwWenKai
[NetworkManager]: https://wiki.gnome.org/Projects/NetworkManager
[network-manager-applet]: https://gitlab.gnome.org/GNOME/network-manager-applet/
[Gruvbox]: https://github.com/morhetz/gruvbox
[Papirus-Dark]: https://github.com/PapirusDevelopmentTeam/papirus-icon-theme
[Bibata-Modern-Ice]: https://www.gnome-look.org/p/1197198
[Colloid gtk theme]: https://github.com/vinceliuice/Colloid-gtk-theme
[OBS]: https://obsproject.com/
