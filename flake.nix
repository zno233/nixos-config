{
  description = "zno's nixos configuration";

  inputs = {
    # Primary channels
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # nixpkgs-stable 25.11
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";

    # Flake-parts
    flake-parts.url = "github:hercules-ci/flake-parts";

    # Kernels / hardware
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

    # Package helpers
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Community overlays
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Utilities / packages
    nix-gaming.url = "github:fufexan/nix-gaming";
    nix-flatpak.url = "github:gmodena/nix-flatpak";
    nix-colors.url = "github:Misterio77/nix-colors";
    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    superfile.url = "github:yorukot/superfile";
    niri = {
      url = "github:sodiboo/niri-flake";
      #inputs.niri-unstable.follows = "niri-unstable";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser.url = "github:0xc000022070/zen-browser-flake/beta";
    daeuniverse.url = "github:daeuniverse/flake.nix";

    # Fonts / others
    maple-mono = {
      url = "github:subframe7536/maple-font/variable";
      flake = false;
    };

    # Optional / commented inputs (kept as-is)
    # lix-module = {
    #   url = "https://git.lix.systems/lix-project/nixos-module/archive/main.tar.gz";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    # caelestia-shell = {
    #   url = "github:caelestia-dots/shell";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    # caelestia-cli = {
    #   url = "github:caelestia-dots/cli";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    #vicinae.url = "github:vicinaehq/vicinae";

    # stylix = {
    #   url = "github:nix-community/stylix";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        ./flake-modules/hosts.nix
      ];

      systems = [ "x86_64-linux" ];

      perSystem =
        { pkgs, ... }:
        {
          formatter = pkgs.nixfmt;
        };
    };
}
