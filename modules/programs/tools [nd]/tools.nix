{ inputs, ... }:
{
  flake.modules.nixos.tools = {
    imports = with inputs.self.modules.nixos; [
      appImage
      nix-ld
    ];
  };

  flake.modules.homeManager.tools = {
    imports = with inputs.self.modules.homeManager; [
      # aseprite
      ebook
      nix-search
      p10k
      # glance
      cli
      mark-shot
      nix-tools
      rclone
      ssh
      tool-apps
      yazi
    ];
  };
}
