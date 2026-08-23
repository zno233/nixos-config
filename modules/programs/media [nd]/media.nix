{ inputs, ... }:
{
  flake.modules.homeManager.media = {
    imports = with inputs.self.modules.homeManager; [
      #audacious
      media-apps
      spotify
    ];
  };
}
