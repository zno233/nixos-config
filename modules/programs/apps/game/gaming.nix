{
  flake.modules.homeManager.gaming =
    { pkgs, inputs, ... }:
    {
      home.packages = with pkgs; [
        ## Utils
        # gamemode
        # gamescope
        winetricks # Helper script for Wine
        wineWow64Packages.waylandFull # Windows compatibility layer with Wayland support
        # inputs.nix-gaming.packages.${pkgs.stdenv.hostPlatform.system}.wine-ge

        ## Minecraft
        # prismlauncher

        ## Cli games
        # _2048
        # _2048-in-terminal
        vitetris
        nethack

        ## Celeste
        # olympus
        # celeste-classic
        # celeste-classic-pm

        ## Doom
        # gzdoom
        crispy-doom

        ## Emulation
        sameboy
        snes9x
        # cemu
        # dolphin-emu
      ];
    };
}
