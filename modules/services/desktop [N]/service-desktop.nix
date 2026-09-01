{ inputs, ... }:
{
  flake.modules.nixos.service-desktop = {
    imports = with inputs.self.modules.nixos; [
      ananicy
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
