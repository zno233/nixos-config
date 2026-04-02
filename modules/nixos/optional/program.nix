{ pkgs, ... }:
{
  programs = {
    xwayland.enable = true;
    dconf.enable = true;
    zsh.enable = true;

    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      # pinentryFlavor = "";
    };

    # has been removed
    # adb.enable = true;

    nix-ld.enable = true;
    nix-ld.libraries = with pkgs; [ ];
  };
}
