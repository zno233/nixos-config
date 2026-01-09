{ ... }:
{
  imports = [
    ./appImage.nix
    #./grub-bootr.nix
    #./sddm.nix 
    ./program.nix
    ./scx.nix
    ./steam.nix
    ./systemd-oomd.nix
    ./flatpak.nix
    #./docker.nix
    ./dae.nix
  ];
}
