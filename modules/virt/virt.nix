{ inputs, ... }:
{
  flake.modules.nixos.virt = {
    imports = with inputs.self.modules.nixos; [
      podman
      # docker
      # virtualization
    ];
  };
}
