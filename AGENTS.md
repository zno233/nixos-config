# AGENTS.md - Agent Guidelines for zno-config

This is a NixOS/nix-darwin/home-manager flake-based configuration using [flake-parts](https://flake.parts) with dendritic module pattern (import-tree + flake-file for auto-generated `flake.nix`).

## Project Structure

```
zno-config/
├── flake.nix              # Auto-generated — DO NOT edit by hand. Regenerate with `nix run .#write-flake`.
├── modules/
│   ├── factory/          # Reusable module templates
│   │   ├── mount-cifs-nixos [N]/
│   │   └── user [ND]/
│   ├── hosts/            # Host-specific configurations (one per machine)
│   │   ├── linux-desktop [N]/
│   │   ├── linux-laptop [N]/
│   │   ├── homeserver [N]/
│   │   └── macbook [D]/
│   ├── nix/              # Nix tooling (flake-parts wiring, home-manager, impermanence, homebrew, agenix secrets, pkgs-by-name)
│   ├── programs/         # Application configurations (flat, tagged category dirs)
│   │   ├── ai [nd]/      # claude-code, opencode, reasonix, agent
│   │   ├── browsers [nd]/# brave, chrome, zen
│   │   ├── cli-tools [ND]/ # platform sets (darwin.nix / nixos.nix / generic.nix)
│   │   ├── de [nd]/      # WM (niri), terminal, shell, theme, file manager, noctalia
│   │   ├── desktop [N]/  # NixOS desktop settings (flake.modules.nixos.settings-desktop)
│   │   ├── dev [nd]/     # nvim, helix, zed, git, dev-tools
│   │   ├── game [nd]/ media [nd]/ note [nd]/ office [nd]/ others [nd]/
│   │   ├── scripts [nd]/ social [nd]/ tools [nd]/
│   │   └── programs.nix  # aggregator → flake.modules.homeManager.programs
│   ├── services/         # System services (desktop [N], fs, printing [N], ssh [ND])
│   ├── system/           # System-level settings
│   │   ├── settings/     # base/, bluetooth [N]/, firmware [N]/, inputMethod/, systemConstants [NDnd]/, systemd-boot [N]/, _network/
│   │   └── system-types/ # Layered types: 1-minimal → 2-default → 3-cli → 4-desktop
│   ├── users/            # User configurations (user flake-parts + meta.nix for metadata)
│   └── virt/             # Virtualization configs
├── pkgs/                 # Custom packages (imported via nixpkgs overlay in system-minimal)
├── secrets/              # Age-encrypted secrets (agenix)
├── wallpapers/           # Wallpaper assets
└── syscheck.sh           # System health/audit script
```

**Directory naming conventions (dendritic tags):**

| Tag | Meaning | Used by |
| --- | --- | --- |
| `[N]` | NixOS only | `hosts/linux-*`, `homeserver`, `services/desktop`, `programs/desktop`, `bluetooth`, `firmware`, `systemd-boot`, `factory/mount-cifs-nixos`, `nix/tools/impermanence` |
| `[D]` | Darwin/macOS only | `hosts/macbook`, `users/alice`, `nix/tools/determinate`, `nix/tools/homebrew` |
| `[ND]` | NixOS + Darwin | `programs/cli-tools`, `services/ssh`, `nix/tools/home-manager`, `factory/user` |
| `[nd]` | home-manager only (lowercase) | all `programs/<category>` dirs (`ai [nd]`, `de [nd]`, …) |
| `[NDn]` | NixOS + Darwin + home-manager, with standalone `homeConfigurations` | `users/zno`, `users/bob` |
| `[NDnd]` | all contexts | `nix/tools/secrets`, `settings/systemConstants`, `system-types/*` |
| `[G]` | generic (class-independent) | `nix/tools/pkgs-by-name` |
| `[]` | flake-parts meta wiring (no aspects) | `nix/flake-parts []` |
| `[networkInterfaces]` | custom DRY class | `settings/_network/subnet-A\|B` |
| *(no tag)* | grouping dir only, not a feature | `hosts/`, `users/`, `programs/`, `services/`, `system/`, `nix/`, `nix/tools/`, `virt/`, `services/fs/`, `settings/base/`, `settings/inputMethod/` |

Tags describe the directory's *primary* context; individual files may additionally register other-class aspects (e.g. `browsers [nd]/brave.nix` also registers `nixos.brave`; `desktop [N]/noctalia-greeter.nix` registers `homeManager.noctalia-greeter`).

## Architecture

### Module Layers (System Types)
System builds compose layers via `modules/system/system-types/`:
1. **`system-minimal`** — base nixpkgs config, overlays (CachyOS kernel, niri, NUR, custom pkgs), substituters, stateVersion
2. **`system-default`** — imports system-minimal
3. **`system-cli`** — imports system-default
4. **`system-desktop`** — imports system-cli + service-desktop + settings-desktop (nixos); system-cli (darwin); system-cli + programs (home-manager)

### Flake Wiring (Dendritic Pattern)
- `modules/nix/flake-parts []/dendritic-tools.nix` — imports flake-parts + flake-file + import-tree modules; defines all `systems`
- `modules/nix/flake-parts []/lib.nix` — defines `flake.lib` helpers: `mkNixos`, `mkDarwin`, `mkHomeManager`
- Each host/user adds a `flake-parts.nix` that calls one of the `mk*` helpers
- Modules register themselves under `flake.modules.nixos.<name>`, `flake.modules.darwin.<name>`, or `flake.modules.homeManager.<name>` depending on target

### User Registration Pattern
- `modules/users/meta.nix` — defines `flake.meta.users` option (homeDirectory, email, configDirectory per user) + `flake.meta.mainUser`
- Factory `modules/factory/user [ND]/user.nix` — creates user with nixos + darwin + home-manager config via `config.flake.factory.user`
- Two coexisting styles:
  - **Standalone** (`zno [NDn]`, `bob [NDn]`): `flake-parts.nix` registers `homeConfigurations.<name>` via `mkHomeManager`; the user is also wired into hosts via `hosts/<host>/users/<name>.nix`
  - **Host-attached** (`alice [D]`, `eve [N]`, `mallory [N]`): no `flake-parts.nix`; pulled in only by `hosts/<host>/users/<name>.nix`

### Program Aggregation Pattern
- Each category dir `modules/programs/<category> [nd]/` has a `<category>.nix` that registers `flake.modules.homeManager.<category>` and imports that category's app modules.
- `modules/programs/programs.nix` registers `flake.modules.homeManager.programs`, importing all categories (`ai`, `browsers`, `de`, …); `system-desktop` (homeManager side) imports `programs`.
- To add a program: create `modules/programs/<category> [nd]/<app>.nix` registering `flake.modules.homeManager.<app>`, and add it to the category's `<category>.nix` imports.

### Desktop Naming — three distinct concepts
- `programs/desktop [N]/` → `flake.modules.nixos.settings-desktop` — NixOS *settings* (fonts, nix-ld, steam, zram, xdg, stylix system layer, …)
- `services/desktop [N]/` → `flake.modules.nixos.service-desktop` — NixOS *services* (pipewire, greetd, dae, flatpak, …)
- `programs/de [nd]/` → `flake.modules.homeManager.de` — home-manager *program category* (wm, terminal, shell, theme)
- Stylix is deliberately split in two layers: `nixos.stylix` (system scaffolding, `autoEnable = false`) and `homeManager.stylix` (per-user theming). Keep them separate.

### mkOutOfStoreSymlink paths (WARNING)
`mkOutOfStoreSymlink` targets use hardcoded repo paths (`${home}/zno-config/modules/...`) in:
- `programs/de [nd]/wm/niri/niri.nix` (`niriConfig`)
- `programs/de [nd]/noctalia/noctalia.nix` (`noctaliaConfig`)
- `programs/dev [nd]/nvim/nvim.nix` (`lazyvimConfig`, currently commented out)

**Any future move of those directories must update these strings in the same commit** — eval does not catch a broken symlink path.

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

# Update inputs
nix flake update
nix flake update nixpkgs
```

### Testing / Dry-run
```bash
# Dry-run (NixOS)
nixos-rebuild dry-run --flake .#linux-desktop

# Dry-build (darwin)
darwin-rebuild dry-build --flake .#macbook

# Check evaluation
nix flake check --no-build
nix build .#packages.x86_64-linux --dry-run
```

## Secrets Management

Secrets use [agenix](https://github.com/ryantm/agenix) with age encryption.

- Encrypted files in `secrets/` with `.age` extension
- Public keys in `secrets/*.pub` files
- Edit secrets with: `nix run .#agenix.edit secrets/deepseek-token.age`
- Secret definitions live in `modules/nix/tools/secrets [NDnd]/secrets.nix`

## Code Style & Conventions

### General
- Use [flake-parts](https://flake.parts/) module system
- **Indentation:** 2 spaces
- Every module goes in a directory: `modules/<category>/<module-name> [tags]/` with at least one `.nix` file
- Module definitions register under `flake.modules.<target>.<name>` (nixos / darwin / homeManager)
- Configuration entry points (`flake-parts.nix`) are kept minimal — just calls `inputs.self.lib.mkNixos/mkDarwin/mkHomeManager`

### Nix Expression Formatting
```nix
{
  config,
  lib,
  pkgs,
  ...
}: {
  # Body
}
```

**Imports:** Order inputs first, then local imports:
```nix
{ inputs, lib, ... }: {
  imports = [
    ./base.nix
    inputs.self.modules.nixos.system-desktop
  ];
}
```

### Naming Conventions
- **Modules**: `kebab-case.nix` (e.g., `system-desktop.nix`)
- **Options**: `config.flake.<name>.<option>` or `config.programs.<programName>`
- **Hosts**: lowercase (e.g., `linux-laptop`, `homeserver`)
- **Users**: lowercase usernames matching system accounts

### Option Definitions
```nix
options.flake.factory.user = lib.mkOption {
  type = lib.types.functionTo lib.types.attrs;
  description = "User configuration factory";
};
```

### Patterns
- Use `lib.mkDefault` for sensible defaults
- Use `lib.mkIf` / `lib.optionals` for conditional config
- Use `lib.warnIf` for deprecation warnings
- Prefer `lib.types.enum` over string checks
- Use `lib.types.functionTo` for factory functions
- Use `lib.types.attrsOf` for grouped options
- Programs are grouped by category (`ai [nd]/`, `de [nd]/`, `dev [nd]/`, `media [nd]/`, `tools [nd]/`, …); each category's `<category>.nix` aggregates its apps and `modules/programs/programs.nix` aggregates all categories

## Common Tasks

### Creating a new host
1. Create directory `modules/hosts/<hostname> [N]/`
2. Add `configuration.nix` with flake module definition (imports system type + per-host aspects)
3. Add `flake-parts.nix` calling `inputs.self.lib.mkNixos "x86_64-linux" "<hostname>"`
4. Add `hardware.nix` / `filesystem.nix` / `users/` as needed

### Adding a program
1. Create module in appropriate `modules/programs/<category> [nd]/` subdirectory, registering `flake.modules.homeManager.<app>`
2. Import it in the category aggregator (e.g., `de [nd]/de.nix`, `dev [nd]/dev.nix`)
3. The category aggregator is already pulled in via `programs.nix` → `homeManager.programs` (no per-host wiring needed)

### Adding a user
1. Standalone: `modules/users/<name> [NDn]/` with `<name>.nix` + `flake-parts.nix` calling `inputs.self.lib.mkHomeManager "<system>" "<name>"`
2. Host-attached: `modules/users/<name> [N|D]/` with `configuration.nix` + `homeManager.nix`, wired in via `hosts/<host>/users/<name>.nix`
3. Register metadata in `modules/users/meta.nix`

### Factory modules
Factory modules in `modules/factory/` create reusable templates:
```nix
config.flake.factory.user = username: isAdmin: { ... };
```

## References
- [NixOS Manual: Module System](https://nixos.org/manual/nixos/stable/#sec-writing-modules)
- [NixOS Library Functions](https://nixos.org/manual/nix/stable/library/)
- [flake-parts Documentation](https://flake.parts/)
- [dendritic-design-with-flake-parts](https://github.com/Doc-Steve/dendritic-design-with-flake-parts) (this config's inspiration)

## Notes
