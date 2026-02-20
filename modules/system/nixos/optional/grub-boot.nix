{ pkgs, ... }:
{
  boot = {
    #开启cake+bbr
    kernel.sysctl = {
      "net.core.default_qdisc" = "cake"; # Zen 内核完美支持
      "net.ipv4.tcp_congestion_control" = "bbr";
      "net.ipv4.tcp_fastopen" = 3; # 额外加成：减少网页握手延迟
    };
    
    kernelPackages = pkgs.linuxPackages_zen;
    supportedFilesystems = ["ntfs"];
    kernelParams = [
      "loglevel=3"
      "quiet"
      "splash"
      "console=tty1"
    ];
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
