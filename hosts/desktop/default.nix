{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./../../modules/system
  ];

  powerManagement.cpuFreqGovernor = "performance";
}
