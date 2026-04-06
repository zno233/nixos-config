{
  inputs,
  ...
}:
{
  flake-file.inputs = {
    # Utilities / packages
    nix-gaming.url = "github:fufexan/nix-gaming";
    nix-colors.url = "github:Misterio77/nix-colors";

    # Fonts / others
    maple-mono = {
      url = "github:subframe7536/maple-font/variable";
      flake = false;
    };
  };
}
