{ pkgs, ... }:
{
  boot = {
    # 核心系统配置
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

    # systemd-boot 引导加载器配置
    loader = {
      systemd-boot.enable = true; 
      grub.enable = false;

      efi.canTouchEfiVariables = true;
      efi.efiSysMountPoint  = "/boot"; # 确保这个设置存在

      systemd-boot.configurationLimit = 10;
    };
    
    plymouth.enable = true; 
  };
}
