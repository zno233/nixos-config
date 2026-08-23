{ inputs, ... }:
{
  flake.modules.nixos.settings-desktop = {
    imports = with inputs.self.modules.nixos; [
      bluetooth
      fcitx5
      fonts
      graphics
      sessionVariables
      stylix
      systemd-oomd
      xdg
      zram
    ];
  };
}
