## Overview

### Noctalia-shell
<details>
<summary>Noctalia-shell (EXPAND)</summary>

<img width="1260" alt="Screenshot from 2026-01-10 12-33-18" src="https://github.com/user-attachments/assets/0b28b5df-9936-4e93-a762-efed37c3e88e" />

</details>

### Waybar
<details>
<summary>Waybar (EXPAND)</summary>

<img width="1260" alt="Screenshot from 2025-12-19 21-16-32" src="https://github.com/user-attachments/assets/37ce7c1f-c7bb-4a6f-b8b9-e5738f9f06e7" />

</details>

---

## System Components & Applications

| Category | Software |
| --- | :--- |
| **Kernel** | [nix-cachyos-kernel][nix-cachyos-kernel] |
| **Window Manager** | [niri][niri] |
| **Shell** | [zsh][zsh] + [powerlevel10k][powerlevel10k] |
| **Terminal** | [kitty][kitty], [ghostty][ghostty] |
| **Bar / Shell** | [noctalia-shell][noctalia-shell] |
| **Launcher** | shell-based (no Rofi) |
| **Notification** | shell-based (no mako/swaync) |
| **Input Method** | [fcitx5][fcitx5] + [rime_wanxiang][rime_wanxiang] |
| **Text Editor** | [neovim][neovim] (LazyVim) + [helix][helix] + [zed][zed] |
| **IDE / Code** | [VSCode][VSCode], [zed][zed] |
| **AI Tools** | [claude-code][claude-code], [opencode][opencode], [reasonix][reasonix] |
| **Network** | [NetworkManager][NetworkManager] + [network-manager-applet][network-manager-applet] |
| **System Monitor** | [btop][btop], [mission-center][mission-center] |
| **File Manager** | [nemo][nemo] |
| **Fonts** | [Maple Mono][Maple Mono] + [HarmonyOS Sans][HarmonyOS Sans] + [LXGW WenKai][LXGW WenKai] |
| **Gtk & Qt Theme** | [stylix][stylix] |
| **Cursor** | [Bibata-Modern-Ice][Bibata-Modern-Ice] |
| **Icons** | [Papirus-Dark][Papirus-Dark] |
| **Browser** | [brave][brave], [zen-browser][zen-browser] |
| **Image Viewer** | [pix][pix] |
| **Media Player** | [mpv][mpv] + [vlc][vlc] |
| **Music Player** | [fooyin][fooyin] + [audacious][audacious] + [spotify][spotify] (spicetify) |
| **Note Taking** | [obsidian][obsidian] |
| **Screen Recording** | [OBS Studio][OBS] |
| **CLI Tools** | [ripgrep][ripgrep], [duf][duf], [gping][gping], [eza][eza], [fd][fd], [broot][broot], [yazi][yazi] … |
| **Nix Tools** | [nvd][nvd], [nix-du][nix-du], [nix-tree][nix-tree], [nix-output-monitor][nix-output-monitor] … |

---

## Hosts

| Host | Arch | Type | Tag |
| --- | --- | --- | --- |
| `linux-desktop` | x86_64-linux | NixOS | `[N]` |
| `linux-laptop` | x86_64-linux | NixOS | `[N]` |
| `homeserver` | x86_64-linux | NixOS | `[N]` |
| `macbook` | aarch64-darwin | nix-darwin | `[D]` |

## Project Structure

```
zno-config/
├── flake.nix              # Auto-generated — DO NOT edit by hand
├── AGENTS.md              # Agent guidelines for AI-assisted development
├── syscheck.sh            # System health/diagnostic script
├── modules/
│   ├── factory/           # Reusable module templates
│   │   ├── mount-cifs-nixos [N]/
│   │   └── user [ND]/
│   ├── hosts/             # Host-specific configurations
│   │   ├── linux-desktop [N]/
│   │   ├── linux-laptop [N]/
│   │   ├── homeserver [N]/
│   │   └── macbook [D]/
│   ├── nix/               # Nix tooling
│   │   ├── flake-parts []/     # dendritic-tools, lib, factory wiring
│   │   └── tools/              # determinate[D], home-manager[ND], homebrew[D],
│   │                              impermanence[N], pkgs-by-name[G], secrets[NDnd]
│   ├── programs/          # Application configurations
│   │   ├── apps/          # Individual apps grouped by category
│   │   │   ├── ai/        #   claude-code, opencode, reasonix
│   │   │   ├── browsers/  #   zen-browser
│   │   │   ├── de/        #   WM (niri), terminal, shell, theme, file manager, noctalia
│   │   │   ├── dev/       #   nvim, helix, zed, git, dev-tools (C/C++, Python, Jupyter)
│   │   │   ├── game/      #   HMCL (Minecraft)
│   │   │   ├── media/     #   mpv, fooyin, spotify, vlc, kazumi, OBS, gimp
│   │   │   ├── note/      #   obsidian
│   │   │   ├── office/    #   WPS Office, LibreOffice
│   │   │   ├── others/    #   misc overrides
│   │   │   ├── scripts/   #   custom scripts
│   │   │   ├── social/    #   discord
│   │   │   └── tools/     #   CLI utils, nix-tools, aseprite, yazi, p10k
│   │   └── app-sets/      # Platform-specific sets
│   │       └── cli-tools [ND]/   # git, tmux, h-m (generic); parted (nixos); mas (darwin)
│   ├── services/          # System services
│   │   ├── desktop [N]/   #   pipewire, greetd, dae, flatpak, scx, xserver, …
│   │   ├── fs/            #   btrfs
│   │   ├── printing [N]/  #   CUPS
│   │   └── ssh [ND]/
│   ├── system/            # System-level settings
│   │   ├── settings/
│   │   │   ├── base/                # i18n, network, nh, security
│   │   │   ├── desktop [N]/
│   │   │   ├── firmware [N]/
│   │   │   ├── systemConstants [NDnd]/
│   │   │   ├── systemd-boot [N]/
│   │   │   └── _network/            # subnet-A, subnet-B
│   │   └── system-types/   # Layered system types
│   │       ├── 1-system-minimal [NDnd]/
│   │       ├── 2-system-default [NDnd]/
│   │       ├── 3-system-cli [NDnd]/
│   │       └── 4-system-desktop [NDnd]/
│   ├── users/             # User configurations
│   │   ├── meta.nix       # User metadata (homeDirectory, email, configDirectory)
│   │   ├── zno [NDn]/     # main user
│   │   ├── alice [D]/
│   │   ├── bob [NDn]/
│   │   ├── eve [N]/
│   │   └── mallory [N]/
│   └── virt/              # Virtualization
│       ├── containers/    # pbh
│       ├── docker.nix
│       ├── podman.nix
│       ├── virt.nix
│       └── virtualization.nix
├── pkgs/                  # Custom packages
│   ├── 2048/              # Game
│   ├── harmonyos-sans/    # Font
│   ├── maple-mono/        # Font
│   ├── mark-shot/         # Screenshot tool
│   └── microsoft-fonts/   # Fonts
├── secrets/               # Age-encrypted secrets (agenix)
└── wallpapers/            # Wallpaper assets
```

## Architecture

### System Types
System builds compose layers via `modules/system/system-types/`:
1. **`1-system-minimal`** — base nixpkgs config, overlays (CachyOS kernel, niri, NUR, custom pkgs), substituters, stateVersion
2. **`2-system-default`** — imports system-minimal
3. **`3-system-cli`** — imports system-default + CLI tools
4. **`4-system-desktop`** — imports system-cli + desktop services + desktop settings

### Flake Wiring (Dendritic Pattern)
- `modules/nix/flake-parts []/dendritic-tools.nix` — imports flake-parts + flake-file + import-tree modules; defines all systems
- `modules/nix/flake-parts []/lib.nix` — defines `flake.lib` helpers: `mkNixos`, `mkDarwin`, `mkHomeManager`
- Each host/user adds a `flake-parts.nix` that calls one of the `mk*` helpers
- Modules register themselves under `flake.modules.nixos.<name>`, `flake.modules.darwin.<name>`, or `flake.modules.homeManager.<name>` depending on target

### User Registration Pattern
- `modules/users/meta.nix` — defines `flake.meta.users` option (homeDirectory, email, configDirectory per user) + `flake.meta.mainUser`
- Factory `modules/factory/user [ND]/user.nix` — creates user with nixos + darwin + home-manager config via `config.flake.factory.user`
- Each user has their own `modules/users/<name> [tags]/` directory with `flake-parts.nix` + config module

## Commands

```bash
# Build NixOS
sudo nixos-rebuild switch --flake .#linux-desktop
sudo nixos-rebuild switch --flake .#linux-laptop
sudo nixos-rebuild switch --flake .#homeserver

# Build darwin
darwin-rebuild switch --flake .#macbook

# Home-manager standalone
home-manager switch --flake .#zno@linux-laptop

# Regenerate flake.nix (after adding/removing inputs in flake-parts)
nix run .#write-flake

# Flake evaluation
nix flake show
nix eval .#nixosConfigurations.linux-laptop.config.system.build.toplevel.name

# System diagnostic
./syscheck.sh              # interactive menu
./syscheck.sh all           # full check
./syscheck.sh --output report.txt  # save report

# Update inputs
nix flake update
```

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
[ghostty]: https://ghostty.org/
[powerlevel10k]: https://github.com/romkatv/powerlevel10k
[btop]: https://github.com/aristocratos/btop
[mission-center]: https://gitlab.com/mission-center-devs/mission-center
[nemo]: https://github.com/linuxmint/nemo/
[zsh]: https://ohmyz.sh/
[fcitx5]: https://github.com/fcitx/fcitx5
[rime_wanxiang]: https://github.com/amzxyz/rime_wanxiang
[neovim]: https://github.com/neovim/neovim
[helix]: https://helix-editor.com/
[zed]: https://zed.dev/
[VSCode]: https://github.com/microsoft/vscode
[opencode]: https://github.com/opencode-ai/opencode
[claude-code]: https://github.com/anthropics/claude-code
[reasonix]: https://github.com/nixos-ai/reasonix
[mpv]: https://github.com/mpv-player/mpv
[vlc]: https://www.videolan.org/vlc/
[fooyin]: https://github.com/fooyin/fooyin
[audacious]: https://audacious-media-player.org/
[spotify]: https://open.spotify.com/
[spicetify-nix]: https://github.com/Gerg-L/spicetify-nix
[obsidian]: https://obsidian.md/
[OBS]: https://obsproject.com/
[zen-browser]: https://zen-browser.app/
[discord]: https://discord.com/
[Maple Mono]: https://github.com/subframe7536/maple-font
[HarmonyOS Sans]: https://developer.huawei.com/consumer/cn/design/resource/
[LXGW WenKai]: https://github.com/lxgw/LxgwWenKai
[NetworkManager]: https://wiki.gnome.org/Projects/NetworkManager
[network-manager-applet]: https://gitlab.gnome.org/GNOME/network-manager-applet/
[Gruvbox]: https://github.com/morhetz/gruvbox
[Papirus-Dark]: https://github.com/PapirusDevelopmentTeam/papirus-icon-theme
[Bibata-Modern-Ice]: https://www.gnome-look.org/p/1197198
[pix]: https://github.com/linuxmint/pix
[ripgrep]: https://github.com/BurntSushi/ripgrep
[duf]: https://github.com/muesli/duf
[gping]: https://github.com/orf/gping
[eza]: https://eza.rocks/
[fd]: https://github.com/sharkdp/fd
[broot]: https://dystroy.org/broot/
[yazi]: https://yazi-rs.github.io/
[nvd]: https://gitlab.com/khumba/nvd
[nix-du]: https://github.com/neffo/nix-du
[nix-tree]: https://github.com/utdemir/nix-tree
[nix-output-monitor]: https://github.com/maralorn/nix-output-monitor
[stylix]:https://github.com/nix-community/stylix
[brave]:https://github.com/brave/brave-browser
[nix-cachyos-kernel]:https://github.com/xddxdd/nix-cachyos-kernel
