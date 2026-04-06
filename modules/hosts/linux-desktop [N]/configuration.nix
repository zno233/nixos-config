{
  inputs,
  ...
}:
{
  flake.modules.nixos.linux-desktop = {
    networking.hostName = "linux-desktop";
    imports = with inputs.self.modules.nixos; [
      system-desktop
      systemd-boot
      bluetooth
    ];
  };
}
