{
  # Nixpak — sandboxing for Nix via bubblewrap
  # https://github.com/nixpak/nixpak

  flake-file.inputs = {
    nixpak = {
      url = "github:nixpak/nixpak";
      inputs.flake-parts.follows = "flake-parts";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
