{
  flake.modules.nixos.system-program = {
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
    };
  };
}
