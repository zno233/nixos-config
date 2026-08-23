## Overview

### Noctalia-shell
<details>
<summary>Noctalia-shell (EXPAND)</summary>

<img width="1260" alt="Screenshot from 2026-08-18 17-39-38" src="https://github.com/user-attachments/assets/982a5ce8-9fa7-463e-a422-61b73c797477" />

<img width="1260" alt="Screenshot from 2026-08-18 17-44-03" src="https://github.com/user-attachments/assets/15328406-7f81-477a-ac77-9cbf1b74b8d4" />



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
│   │   └── tools/              # determinate [D], home-manager [ND], homebrew [D],
│   │                              impermanence [N], pkgs-by-name [G], secrets [NDnd]
│   ├── programs/          # Application configurations
│   │   ├── ai [nd]/       #   claude-code, opencode, reasonix, agent
│   │   ├── browsers [nd]/ #   brave, chrome, zen
│   │   ├── cli-tools [ND]/#   git, tmux, h-m (generic); parted (nixos); mas (darwin)
│   │   ├── de [nd]/       #   WM (niri), terminal, shell, theme, file manager, noctalia
│   │   ├── desktop [N]/   #   NixOS desktop settings (settings-desktop)
│   │   ├── dev [nd]/      #   nvim, helix, zed, git, dev-tools (C/C++, Python, Jupyter)
│   │   ├── game [nd]/     #   gaming packages
│   │   ├── media [nd]/    #   mpv, fooyin, spotify, vlc, audacious
│   │   ├── note [nd]/     #   obsidian
│   │   ├── office [nd]/   #   WPS Office, LibreOffice
│   │   ├── others [nd]/   #   misc overrides, rime
│   │   ├── scripts [nd]/  #   custom scripts
│   │   ├── social [nd]/   #   discord
│   │   ├── tools [nd]/    #   CLI utils, nix-tools, aseprite, yazi, p10k
│   │   └── programs.nix   #   aggregator -> flake.modules.homeManager.programs
│   ├── services/          # System services
│   │   ├── desktop [N]/   #   pipewire, greetd, dae, flatpak, scx, xserver, …
│   │   ├── fs/            #   btrfs
│   │   ├── printing [N]/  #   CUPS
│   │   └── ssh [ND]/
│   ├── system/            # System-level settings
│   │   ├── settings/
│   │   │   ├── base/                # i18n, network, nh, security
│   │   │   ├── bluetooth [N]/
│   │   │   ├── firmware [N]/
│   │   │   ├── inputMethod/         # fcitx5
│   │   │   ├── systemConstants [NDnd]/
│   │   │   ├── systemd-boot [N]/
│   │   │   └── _network/            # subnet-A [networkInterfaces], subnet-B
│   │   └── system-types/   # Layered system types
│   │       ├── 1 - system-minimal [NDnd]/
│   │       ├── 2 - system-default [NDnd]/
│   │       ├── 3 - system-cli [NDnd]/
│   │       └── 4 - system-desktop [NDnd]/
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
├── pkgs/                  # Custom packages (imported via pkgs-by-name overlay)
│   ├── 2048/              # Game
│   ├── fooyin/
│   ├── harmonyos-sans/    # Font
│   ├── maple-mono/        # Font
│   ├── mark-shot/         # Screenshot tool
│   ├── microsoft-fonts/   # Fonts
│   └── splayer-next/
├── secrets/               # Age-encrypted secrets (agenix)
└── wallpapers/            # Wallpaper assets
```

## Directory Tag Legend

Bracket suffixes in directory names are literal and describe the feature's usage contexts (dendritic convention):

| Tag | Meaning | Used by |
| --- | --- | --- |
| `[N]` | NixOS only | `hosts/linux-*`, `homeserver`, `bluetooth`, `firmware`, `systemd-boot`, `programs/desktop` |
| `[D]` | Darwin/macOS only | `hosts/macbook`, `users/alice`, `nix/tools/determinate`, `homebrew` |
| `[ND]` | NixOS + Darwin | `programs/cli-tools`, `services/ssh`, `nix/tools/home-manager`, `factory/user` |
| `[nd]` | home-manager only (lowercase) | all `programs/<category>` dirs |
| `[NDn]` | NixOS + Darwin + home-manager, with standalone `homeConfigurations` | `users/zno`, `users/bob` |
| `[NDnd]` | all contexts | `nix/tools/secrets`, `systemConstants`, `system-types/*` |
| `[G]` | generic (class-independent) | `nix/tools/pkgs-by-name` |
| `[]` | flake-parts meta wiring (no aspects) | `nix/flake-parts []` |
| `[networkInterfaces]` | custom DRY class | `settings/_network/subnet-*` |
| *(no tag)* | grouping dir only, not a feature | `hosts/`, `users/`, `programs/`, `services/`, `system/`, `nix/`, `virt/` |

Tags describe the directory's *primary* context; individual files may additionally register other-class aspects (e.g. `browsers [nd]/brave.nix` also registers `nixos.brave`).

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
- Two coexisting styles:
  - **Standalone** (`zno [NDn]`, `bob [NDn]`): `flake-parts.nix` registers a standalone `homeConfigurations.<name>` via `mkHomeManager`; the user is also wired into hosts via `hosts/<host>/users/<name>.nix`
  - **Host-attached** (`alice [D]`, `eve [N]`, `mallory [N]`): no `flake-parts.nix`; pulled in only by `hosts/<host>/users/<name>.nix`

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
home-manager build --flake .#bob

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
