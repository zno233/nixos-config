{ pkgs, meta, ... }:
{
  # Add user to libvirtd group
  users.users.${meta.userName}.extraGroups = [ "libvirtd" ];

  # Install necessary packages
  environment.systemPackages = with pkgs; [
    virt-manager
    virt-viewer
    spice
    spice-gtk
    spice-protocol
    virtio-win
    win-spice
    adwaita-icon-theme
  ];

  # Manage the virtualisation services
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        swtpm.enable = true;
      };
    };

    # waydroid.enable = true;

    spiceUSBRedirection.enable = true;
  };
  services.spice-vdagentd.enable = true;
}
