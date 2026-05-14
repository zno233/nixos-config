{
  inputs,
  ...
}:
{
  flake-file.inputs = {
    # Primary channels
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # nixpkgs-stable 25.11
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";

    # Kernels / hardware
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

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
    niri = {
      url = "github:sodiboo/niri-flake";
      #inputs.niri-unstable.follows = "niri-unstable";
    };

    # Utilities / packages
    nix-gaming.url = "github:fufexan/nix-gaming";
    nix-colors.url = "github:Misterio77/nix-colors";

    # Fonts / others
    maple-mono = {
      url = "github:subframe7536/maple-font/variable";
      flake = false;
    };

    # Optional / commented inputs (kept as-is)

    # stylix = {
    #   url = "github:nix-community/stylix";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

  };
}
