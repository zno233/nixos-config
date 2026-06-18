{ inputs, ... }:
{
  flake.modules.nixos.service-desktop = {
    imports = with inputs.self.modules.nixos; [
      aria2
      dae
      flatpak
      greetd
      pipewire
      scx
      # sddm
      services
      xserver
    ];
  };
}
