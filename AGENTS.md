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
│   ├── programs/         # Application configurations
│   │   ├── apps/         # Individual apps grouped by category (de/, dev/, media/, tools/, …)
│   │   └── app-sets/     # Platform-specific sets (cli-tools has darwin.nix / nixos.nix / generic.nix)
│   ├── services/         # System services
│   ├── system/           # System-level settings
│   │   ├── settings/     # base/, desktop[N]/, firmware[N]/, systemConstants[NDnd]/
│   │   └── system-types/ # Layered types: 1-minimal → 2-default → 3-cli → 4-desktop
│   ├── users/            # User configurations (user flake-parts + meta.nix for metadata)
│   └── virt/             # Virtualization configs
├── pkgs/                 # Custom packages (imported via nixpkgs overlay in system-minimal)
├── secrets/              # Age-encrypted secrets (agenix)
├── wallpapers/           # Wallpaper assets
└── syscheck.sh           # System health/audit script
```

**Directory naming conventions:**
- `[N]` = NixOS only, `[D]` = Darwin/macOS only, `[ND]` = NixOS + Darwin, `[NDnd]` = NixOS + Darwin + home-manager, `[G]` = generic

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
- Each user has their own `modules/users/<name> [NDn]/` directory with `flake-parts.nix` + config module

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
- Programs are grouped by category (de/, dev/, media/, tools/, …) and imported by `modules/programs/programs.nix`

## Common Tasks

### Creating a new host
1. Create directory `modules/hosts/<hostname> [N]/`
2. Add `configuration.nix` with flake module definition
3. Add `flake-parts.nix` calling `inputs.self.lib.mkNixos "x86_64-linux" "<hostname>"`
4. Add `users/` subdirectory for user configs if needed

### Adding a program
1. Create module in appropriate `modules/programs/apps/<category>/` subdirectory
2. Import in parent category module (e.g., `de.nix`, `dev.nix`)
3. Make sure the parent category is imported in a host or user config

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
