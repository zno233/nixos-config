{ inputs, ... }:
{
  flake.modules.homeManager.tools = {
    imports = with inputs.self.modules.homeManager; [
      aseprite
      nix-search
      p10k
      # glance
      cli
      nix-tools
      ssh
    ];
  };
}
