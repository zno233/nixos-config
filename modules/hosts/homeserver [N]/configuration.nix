{
  inputs,
  ...
}:
{
  flake.modules.nixos.homeserver = {
    networking.hostName = "homeserver";
    imports = with inputs.self.modules.nixos; [
      system-cli
      systemd-boot
      impermanence
    ];
  };
  ###
}
