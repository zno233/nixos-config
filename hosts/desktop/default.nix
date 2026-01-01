{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./../../modules/nixos
  ];

  powerManagement.cpuFreqGovernor = "performance";
}
