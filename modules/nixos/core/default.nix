{ ... }:
{
  imports = [
    ./nixpkgs.nix
    ./graphics.nix
    ./xserver.nix
    ./network.nix
    ./nh.nix
    ./pipewire.nix
    ./greetd.nix
    ./security.nix
    ./services.nix
    ./system.nix
    ./systemd-boot.nix
    ./user.nix
    ./xdg.nix
    ./virtualization.nix
    ./bluetooth.nix
    ./fcitx5.nix
    ./font.nix
  ];
}
