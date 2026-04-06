{
  inputs,
  ...
}:
{
  flake.modules.nixos.linux-laptop = {
    networking.hostName = "linux-laptop";
    imports = with inputs.self.modules.nixos; [
      system-desktop
      systemd-boot
      laptop-power
    ];
  };
}
