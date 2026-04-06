{
  flake.modules.nixos.security =
    { ... }:
    {
      security = {
        rtkit.enable = true;
        sudo.enable = true;

        pam.services = {
          swaylock = { };
          hyprlock = { };
        };
      };
    };
}
