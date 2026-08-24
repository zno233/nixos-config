{
  inputs,
  ...
}:
{
  flake-file.inputs = {
    # Primary channels
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # nixpkgs-stable 26.05
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-26.05";

    # Community overlays
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Utilities / packages
    # nix-colors.url = "github:Misterio77/nix-colors";

    # Fonts / others
    # maple-mono = {
    #   url = "github:subframe7536/maple-font/variable";
    #   flake = false;
    # };
  };
}
