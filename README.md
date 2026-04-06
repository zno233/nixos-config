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
├─ modules
│  ├─ factory
│  │  ├─ mount-cifs-nixos [N]
│  │  │  └─ mount-cifs-nixos.nix
│  │  └─ user [ND]
│  │     └─ user.nix
│  ├─ hosts
│  │  ├─ homeserver [N]
│  │  │  ├─ configuration.nix
│  │  │  ├─ filesystem.nix
│  │  │  ├─ flake-parts.nix
│  │  │  ├─ hardware.nix
│  │  │  ├─ network.nix
│  │  │  ├─ services
│  │  │  │  ├─ iperf.nix
│  │  │  │  └─ syncthing
│  │  │  │     ├─ syncthing.nix
│  │  │  │     └─ syncthingDevices.nix
│  │  │  └─ users
│  │  │     ├─ eve.nix
│  │  │     └─ mallory.nix
│  │  ├─ linux-desktop [N]
│  │  │  ├─ configuration.nix
│  │  │  ├─ filesystem.nix
│  │  │  ├─ flake-parts.nix
│  │  │  ├─ hardware.nix
│  │  │  └─ users
│  │  │     └─ bob.nix
│  │  ├─ linux-laptop [N]
│  │  │  ├─ _hardware-configuration.nix
│  │  │  ├─ configuration.nix
│  │  │  ├─ default.nix
│  │  │  ├─ fileSystems.nix
│  │  │  ├─ flake-parts.nix
│  │  │  ├─ hardware.nix
│  │  │  └─ users
│  │  │     └─ zno.nix
│  │  └─ macbook [D]
│  │     ├─ configuration.nix
│  │     ├─ flake-parts.nix
│  │     └─ users
│  │        ├─ alice.nix
│  │        └─ bob.nix
│  ├─ nix
│  │  ├─ flake-parts []
│  │  │  ├─ darwinConfigurations-fix.nix
│  │  │  ├─ dendritic-tools.nix
│  │  │  ├─ factory.nix
│  │  │  ├─ lib.nix
│  │  │  └─ others.nix
│  │  └─ tools
│  │     ├─ determinate [D]
│  │     │  ├─ determinate.nix
│  │     │  └─ flake-parts.nix
│  │     ├─ home-manager [ND]
│  │     │  ├─ flake-parts.nix
│  │     │  └─ home-manager.nix
│  │     ├─ homebrew [D]
│  │     │  ├─ flake-parts.nix
│  │     │  └─ homebrew.nix
│  │     ├─ impermanence [N]
│  │     │  ├─ flake-parts.nix
│  │     │  ├─ impermanence.nix
│  │     │  └─ minimum.nix
│  │     ├─ pkgs-by-name [G]
│  │     │  ├─ flake-parts.nix
│  │     │  └─ pkgs-by-name.nix
│  │     └─ secrets [NDnd]
│  │        ├─ flake-parts.nix
│  │        └─ secrets.nix
│  ├─ programs
│  │  ├─ app-sets
│  │  │  └─ cli-tools [ND]
│  │  │     ├─ darwin.nix
│  │  │     ├─ generic.nix
│  │  │     └─ nixos.nix
│  │  ├─ apps
│  │  │  ├─ ai
│  │  │  │  ├─ ai.nix
│  │  │  │  ├─ gemini-cli.nix
│  │  │  │  └─ ollama.nix
│  │  │  ├─ browsers
│  │  │  │  ├─ browsers.nix
│  │  │  │  ├─ chrome.nix
│  │  │  │  └─ zen.nix
│  │  │  ├─ de
│  │  │  │  ├─ _caelestia.nix
│  │  │  │  ├─ _fish.nix
│  │  │  │  ├─ _hyprlock
│  │  │  │  ├─ _micro.nix
│  │  │  │  ├─ _rofi
│  │  │  │  ├─ _superfile
│  │  │  │  ├─ _swaylock.nix
│  │  │  │  ├─ _swaync
│  │  │  │  ├─ _swayosd.nix
│  │  │  │  ├─ _vicinae
│  │  │  │  ├─ _waybar
│  │  │  │  ├─ _waypaper.nix
│  │  │  │  ├─ bat.nix
│  │  │  │  ├─ btop.nix
│  │  │  │  ├─ cava.nix
│  │  │  │  ├─ de.nix
│  │  │  │  ├─ fastfetch
│  │  │  │  ├─ fzf.nix
│  │  │  │  ├─ ghostty
│  │  │  │  ├─ gnome.nix
│  │  │  │  ├─ gtk.nix
│  │  │  │  ├─ kitty.nix
│  │  │  │  ├─ nemo.nix
│  │  │  │  ├─ noctalia
│  │  │  │  │  └─ noctalia.nix
│  │  │  │  ├─ wm
│  │  │  │  │  ├─ _hyprland
│  │  │  │  │  ├─ niri
│  │  │  │  │  └─ wm.nix
│  │  │  │  ├─ xdg-mimes.nix
│  │  │  │  └─ zsh
│  │  │  ├─ dev
│  │  │  │  ├─ dev-tools.nix
│  │  │  │  ├─ dev.nix
│  │  │  │  ├─ git.nix
│  │  │  │  ├─ lazygit.nix
│  │  │  │  └─ nvim
│  │  │  ├─ game
│  │  │  ├─ media
│  │  │  ├─ note
│  │  │  ├─ office
│  │  │  ├─ others
│  │  │  ├─ scripts
│  │  │  ├─ social
│  │  │  └─ tools
│  │  └─ programs.nix
│  ├─ services
│  │  ├─ desktop [N]
│  │  │  ├─ aria2.nix
│  │  │  ├─ dae.nix
│  │  │  ├─ flatpak.nix
│  │  │  ├─ fprintd.nix
│  │  │  ├─ greetd.nix
│  │  │  ├─ grub-boot.nix
│  │  │  ├─ laptop-power.nix
│  │  │  ├─ pipewire.nix
│  │  │  ├─ scx.nix
│  │  │  ├─ sddm.nix
│  │  │  ├─ service-desktop.nix
│  │  │  ├─ services.nix
│  │  │  ├─ tomcat.nix
│  │  │  └─ xserver.nix
│  │  ├─ printing [N]
│  │  │  └─ printing.nix
│  │  └─ ssh [ND]
│  │     └─ ssh.nix
│  ├─ system
│  │  ├─ settings
│  │  │  ├─ _network
│  │  │  │  ├─ subnet-A [networkInterfaces]
│  │  │  │  │  └─ subnet-A.nix
│  │  │  │  └─ subnet-B [networkInterfaces]
│  │  │  │     └─ subnet-B.nix
│  │  │  ├─ base
│  │  │  │  ├─ i18n.nix
│  │  │  │  ├─ network.nix
│  │  │  │  ├─ nh.nix
│  │  │  │  ├─ security.nix
│  │  │  │  └─ system-base.nix
│  │  │  ├─ desktop [N]
│  │  │  │  ├─ appImage.nix
│  │  │  │  ├─ bluetooth.nix
│  │  │  │  ├─ desktop.nix
│  │  │  │  ├─ fcitx5.nix
│  │  │  │  ├─ fonts.nix
│  │  │  │  ├─ graphics.nix
│  │  │  │  ├─ sessionVariables.nix
│  │  │  │  ├─ steam.nix
│  │  │  │  ├─ system-program.nix
│  │  │  │  ├─ xdg.nix
│  │  │  │  └─ zram.nix
│  │  │  ├─ firmware [N]
│  │  │  │  └─ firmware.nix
│  │  │  ├─ systemConstants [NDnd]
│  │  │  │  └─ systemConstants.nix
│  │  │  └─ systemd-boot [N]
│  │  │     └─ systemd-boot.nix
│  │  └─ system-types
│  │     ├─ 1 - system-minimal [NDnd]
│  │     │  ├─ darwin
│  │     │  │  ├─ darwin-minimal.nix
│  │     │  │  ├─ flake-parts.nix
│  │     │  │  └─ macos-apps-fix.nix
│  │     │  ├─ homeManager
│  │     │  │  └─ homeManager-minimal.nix
│  │     │  └─ nixos
│  │     │     ├─ flake-parts.nix
│  │     │     └─ nixos-minimal.nix
│  │     ├─ 2 - system-default [NDnd]
│  │     │  └─ system-default.nix
│  │     ├─ 3 - system-cli [NDnd]
│  │     │  └─ system-cli.nix
│  │     └─ 4 - system-desktop [NDnd]
│  │        └─ system-desktop.nix
│  ├─ users
│  │  ├─ alice [D]
│  │  │  ├─ configuration.nix
│  │  │  └─ homeManager.nix
│  │  ├─ bob [NDn]
│  │  │  ├─ bob.nix
│  │  │  └─ flake-parts.nix
│  │  ├─ eve [N]
│  │  │  ├─ configuration.nix
│  │  │  └─ homeManager.nix
│  │  ├─ mallory [N]
│  │  │  └─ malory.nix
│  │  ├─ meta.nix
│  │  └─ zno [NDn]
│  │     ├─ flake-parts.nix
│  │     └─ zno.nix
│  └─ virt
│     ├─ distrobox.nix
│     ├─ docker.nix
│     ├─ virt.nix
│     └─ virtualization.nix
├─ pkgs
│  ├─ 2048
│  │  └─ default.nix
│  ├─ default.nix
│  └─ maple-mono
│     └─ default.nix
├─ secrets
│  └─ homeserver-cred.age
└─ wallpapers

```

---
## Credits
Other dotfiles that I ~~copied~~ learned from:
 - [dendritic-design-with-flake-parts](https://github.com/Doc-Steve/dendritic-design-with-flake-parts)
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