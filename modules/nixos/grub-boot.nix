{ pkgs, ... }:
{
  boot = {
    kernelPackages = pkgs.linuxPackages_zen;
    supportedFilesystems = ["ntfs"];
    kernelParams = [
      "loglevel=3"
      "quiet"
      "splash"
      "console=tty1"
    ];
    consoleLogLevel = 0;
    initrd.verbose = false;
    loader = {
      systemd-boot.enable = false;
      grub = {
        enable = true;
        copyKernels = false;
        device = "nodev";
        useOSProber = true;
        efiSupport = true;
        #efiInstallAsRemovable = true;
        extraEntriesBeforeNixOS = true;
        extraEntries = ''
          menuentry "Reboot" {
            reboot
        }
          menuentry "Poweroff" {
            halt
        }
      '';
      default = "NixOS";
    };
    efi.efiSysMountPoint  = "/boot";
    efi.canTouchEfiVariables = true;
  };
  plymouth.enable = true; 
 };
}
