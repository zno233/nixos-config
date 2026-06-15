{ inputs, ... }:
{
  flake.modules.homeManager.tools = {
    imports = with inputs.self.modules.homeManager; [
      aseprite
      ebook
      nix-search
      p10k
      # glance
      cli
      nix-tools
      rclone
      ssh
      tool-apps
      yazi
    ];
  };
}
