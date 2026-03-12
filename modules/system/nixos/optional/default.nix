{ ... }:
{
  imports = [
    ./appImage.nix
    #./grub-bootr.nix
    #./sddm.nix
    #./fprintd.nix
    ./program.nix
    ./scx.nix
    ./steam.nix
    ./systemd-oomd.nix
    ./flatpak.nix
    #./docker.nix
    ./dae.nix
    ./zram.nix
  ];
}
