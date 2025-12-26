{ ... }:
{
  imports = [
    ./appImage.nix
    ./nixpkgs.nix
    #./grub-bootr.nix
    ./systemd-boot.nix
    ./greetd.nix
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
    ./xdg.nix
    ./virtualization.nix
    ./bluetooth.nix
    #./docker.nix
    ./dae.nix
    ./fcitx5.nix
  ];
}
