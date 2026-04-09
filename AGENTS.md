# AGENTS.md - Agent Guidelines for zno-config

This is a NixOS/nix-darwin/home-manager flake-based configuration using [flake-parts](https://flake.parts).

## Project Structure

```
zno-config/
├── flake.nix              # Main flake file
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

**Directory naming conventions:**
- `[N]` = NixOS only, `[D]` = Darwin/macOS only, `[ND]` = NixOS + Darwin, `[NDn]` = NixOS + Darwin + home-manager

---

## Build Commands

```bash
# Build NixOS
sudo nixos-rebuild switch --flake .#linux-desktop
sudo nixos-rebuild switch --flake .#homeserver

# Build darwin
darwin-rebuild switch --flake .#macbook

# Home-manager
home-manager switch --flake .#zno@linux-laptop

# Flake evaluation
nix flake show
nix eval .#nixosConfigurations.linux-laptop.config.system.build.toplevel.name

# Update inputs
nix flake update
nix flake update nixpkgs
```

---

## Testing

```bash
# Dry-run (NixOS)
nixos-rebuild dry-run --flake .#linux-desktop

# Dry-run (darwin)
darwin-rebuild dry-build --flake .#macbook

# Nix evaluation check
nix-instantiate --parse modules/**/*.nix
nix build .#Packages.x86_64-linux --dry-run
```

---

## Code Style Guidelines

### General Principles
- Use [flake-parts](https://flake.parts/) module system
- Follow existing module structure patterns
- Use descriptive names for modules and options
- **Indentation:** 2 spaces

### Nix Expression Formatting

**Attribute sets:**
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
- **Options**: `flake.lib.optionName` or `config.programs.programName`
- **Hosts**: lowercase (e.g., `linux-laptop`, `homeserver`)
- **Users**: lowercase usernames matching system accounts

### Option Definitions
```nix
options.flake.factory.user = lib.mkOption {
  type = lib.types.functionTo lib.types.attrs;
  description = "User configuration factory";
};
```

### Error Handling
- Use `lib.mkDefault` for sensible defaults
- Use `lib.mkIf` / `lib.optionals` for conditional config
- Use `lib.warnIf` for deprecation warnings

### Type System
- Prefer `lib.types.enum` over string checks
- Use `lib.types.functionTo` for factory functions
- Use `lib.types.attrsOf` for grouped options

### References
- [NixOS Manual: Module System](https://nixos.org/manual/nixos/stable/#sec-writing-modules)
- [NixOS Library Functions](https://nixos.org/manual/nix/stable/library/)
- [flake-parts Documentation](https://flake.parts/)

---

## Secrets Management

Secrets use [agenix](https://github.com/ryantm/agenix) with age encryption.

- Secrets in `secrets/` directory with `.age` extension
- Public keys in `secrets/*.pub` files
- Edit secrets with: `nix run .#agenix.edit secrets/homeserver-cred.age`

---

## Common Patterns

### Creating a new host
1. Create directory `modules/hosts/<hostname> [N]/`
2. Add `configuration.nix` with flake module definition
3. Add `users/` subdirectory for user configs

### Adding a program
1. Create module in appropriate `modules/programs/apps/` subdirectory
2. Import in parent module (e.g., `de.nix`, `dev.nix`)
3. Import parent in host or user config

### Factory modules
Factory modules in `modules/factory/` create reusable templates:
```nix
config.flake.factory.user = username: isAdmin: { ... };
```