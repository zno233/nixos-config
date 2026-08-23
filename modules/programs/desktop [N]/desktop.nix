{ inputs, ... }:
{
  flake.modules.nixos.settings-desktop = {
    imports = with inputs.self.modules.nixos; [
      appImage
      brave
      # chromium
      fonts
      graphics
      nix-ld
      # qylock
      steam
      stylix
      system-program
      systemd-oomd
      sessionVariables
      xdg
      zram
    ];
  };
}
