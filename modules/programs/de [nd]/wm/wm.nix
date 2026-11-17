{
  inputs,
  ...
}:
{
  flake.modules.nixos.wm = {
    imports = with inputs.self.modules.nixos; [
      niri
      umbriel
    ];
  };

  flake.modules.homeManager.wm = {
    imports = with inputs.self.modules.homeManager; [
      # niri
      # hyprland
    ];
  };
}
