{ ... }:
{
  imports = [
    ./appImage.nix
    ./nixpkgs.nix
    #./bootloader.nix
    ./oldBootloader.nix
    ./hardware.nix
    ./xserver.nix
    ./network.nix
    ./nh.nix
    ./pipewire.nix
    ./program.nix
    ./security.nix
    ./services.nix
    ./steam.nix
    ./system.nix
    ./flatpak.nix
    ./user.nix
    ./wayland.nix
    ./virtualization.nix
    ./bluetooth.nix
    ./docker.nix
    ./dae.nix
  ];
}
