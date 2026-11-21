{
  inputs,
  ...
}:
{
  flake.modules.homeManager.media = {
    imports = with inputs.self.modules.homeManager; [
      # audacious
      ebook
      media-apps
      # sonora
      # spotify
    ];
  };
}
