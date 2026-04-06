{ inputs, ... }:
{
  flake.modules.homeManager.wm = {
    imports = with inputs.self.modules.homeManager; [
      niri
      #hyprland
    ];
  };
}
