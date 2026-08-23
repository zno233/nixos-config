{
  self,
  ...
}:
{
  flake-file.inputs = {
    qylock = {
      url = "github:Darkkal44/qylock";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.modules.nixos.qylock =
    {
      pkgs,
      ...
    }:
    {
      imports = [
        self.inputs.qylock.nixosModules.default
      ];

      # services.displayManager.sddm.enable = true;
      # services.displayManager.sddm.wayland.enable = true;
      # services.displayManager.sessionPackages = [ pkgs.niri ];
      # security.pam.services.sddm.enableGnomeKeyring = true;

      programs.qylock = {
        enable = true;
        theme = "nier-automata"; # any directory name under themes/
        sddm.enable = false; # installs theme + sets it active (default)
        quickshell.enable = true; # adds `qylock-lock` to PATH (default)

        # Optional per-theme tweaks (replaces the interactive prompts):
        themeOptions = {
          terraria.backgroundMode = "time"; # time | random | static
          Genshin.backgroundMode = "time";
          clockwork.orbital = {
            themeMode = "dark";
            enableWindup = true;
          };
          osu.gameMode = "menu"; # menu | game
        };
      };

    };
}
