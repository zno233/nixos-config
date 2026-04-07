{ inputs, ... }:
{
  flake.modules.nixos.settings-desktop = {
    imports = with inputs.self.modules.nixos; [
      appImage
      bluetooth
      fcitx5
      fonts
      graphics
      system-program
      systemd-oomd
      sessionVariables
      steam
      xdg
      zram
    ];
  };
}
