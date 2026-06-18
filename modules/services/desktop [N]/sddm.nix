{
  flake.modules.nixos.sddm =
    {
      pkgs,
      ...
    }:
    let
      sddm-astronaut =
        (pkgs.sddm-astronaut.override {
          embeddedTheme = "pixel_sakura"; # or any other theme
          # themeConfig = {
          #   # Customize colors and settings
          #   HeaderTextColor = "#d5c4a1";
          #   Background = "Backgrounds/your-custom-background.png";
          #   # ... other theme configuration options
          # };
        }).overrideAttrs
          (oldAttrs: {
            # Optional: Inject custom background image
            # installPhase = oldAttrs.installPhase + ''
            #   chmod u+w $out/share/sddm/themes/sddm-astronaut-theme/Backgrounds/
            #   cp ${./relative/path/to/your-custom-background.png} \
            #     $out/share/sddm/themes/sddm-astronaut-theme/Backgrounds/your-custom-background.png
            # '';
          });
    in
    {
      environment.systemPackages = [ sddm-astronaut ];

      services.displayManager.sddm = {
        enable = true;
        package = pkgs.kdePackages.sddm;
        extraPackages = with pkgs; [
          kdePackages.qtmultimedia # Required for video backgrounds/audio
        ];
        theme = "sddm-astronaut-theme";
      };

      services.displayManager.sessionPackages = [ pkgs.niri ];

      # unlock GPG keyring on login
      security.pam.services.greetd.enableGnomeKeyring = true;
    };
}
