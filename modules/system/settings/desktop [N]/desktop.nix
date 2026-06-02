{ inputs, ... }:
{
  flake.modules.nixos.settings-desktop = {
    imports = with inputs.self.modules.nixos; [
      appImage
      bluetooth
      brave
      # chromium
      fcitx5
      fonts
      graphics
      stylix
      system-program
      systemd-oomd
      sessionVariables
      steam
      xdg
      zram
    ];
  };
}
