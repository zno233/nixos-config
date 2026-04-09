## Overview

### Noctalia-shell
<details>
<summary>Noctalia-shell (EXPAND)</summary>

<img width="2520" height="1680" alt="Screenshot from 2026-01-10 12-33-18" src="https://github.com/user-attachments/assets/0b28b5df-9936-4e93-a762-efed37c3e88e" />

</details>

### Waybar
<details>
<summary>Waybar (EXPAND)</summary>

<img width="2520" height="1680" alt="Screenshot from 2025-12-19 21-16-32" src="https://github.com/user-attachments/assets/37ce7c1f-c7bb-4a6f-b8b9-e5738f9f06e7" />

</details>

---
## System Components & Applications

| Component | Software |
| --- | :---: |
| **Kernel**                  | [nix-cachyos-kernel][nix-cachyos-kernel] |
| **Window Manager**          | [niri][niri] |
| **Bar**                     | [noctalia-shell][noctalia-shell] |
| **Terminal Emulator**       | [kitty][kitty] |
| **Shell**                   | [zsh][zsh] + [powerlevel10k][powerlevel10k] |
| **Input Method**            | [fcitx5][fcitx5] + [rime_wanxiang][rime_wanxiang] |
| **Text Editor**             | [VSCode][VSCode] + [lazyvim][lazyvim] |
| **network management tool** | [NetworkManager][NetworkManager] + [network-manager-applet][network-manager-applet] |
| **System resource monitor** | [btop][btop] |
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
## Project Structure
```
nixos-config/
├── flake.nix             # Main flake file
├── modules/
│   ├── factory/          # Reusable module templates
│   ├── hosts/            # Host-specific configurations
│   │   ├── linux-desktop [N]/
│   │   ├── linux-laptop [N]/
│   │   ├── homeserver [N]/
│   │   └── macbook [D]/
│   ├── nix/              # Nix tooling (home-manager, impermanence)
│   ├── programs/         # Application configurations
│   ├── services/         # System services
│   ├── system/           # System-level settings
│   ├── users/            # User configurations
│   └── virt/             # Virtualization configs
├── pkgs/                 # Custom packages
├── secrets/              # Age-encrypted secrets (agenix)
└── wallpapers/           # Wallpaper assets

```

---
## Credits
Other dotfiles that I ~~copied~~ learned from:
 - [dendritic-design-with-flake-parts](https://github.com/Doc-Steve/dendritic-design-with-flake-parts)
 - [ryan4yin/nix-config](https://github.com/ryan4yin/nix-config)
 - [Frost-Phoenix/nixos-config](https://github.com/Frost-Phoenix/nixos-config)



<!-- Links -->

[nix-cachyos-kernel]: https://github.com/xddxdd/nix-cachyos-kernel
[niri]: https://github.com/niri-wm/niri
[noctalia-shell]: https://github.com/noctalia-dev/noctalia-shell
[kitty]: https://sw.kovidgoyal.net/kitty/
[powerlevel10k]: https://github.com/romkatv/powerlevel10k
[btop]: https://github.com/aristocratos/btop
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