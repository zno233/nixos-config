{ pkgs, ... }:
{
  programs = {
    dconf.enable = true;
    zsh.enable = true;

    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      # pinentryFlavor = "";
    };

    xwayland.enable = true;
    nix-ld.enable = true;
    nix-ld.libraries = with pkgs; [ ];
  };
}
