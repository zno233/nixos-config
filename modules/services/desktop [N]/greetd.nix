{
  self,
  ...
}:
{
  flake.modules.nixos.greetd =
    { pkgs, ... }:
    {
      services.greetd = {
        enable = true;
        settings = {
          terminal.vt = 1;
          default_session = {
            command = "${pkgs.tuigreet}/bin/tuigreet --time --time-format \"%H:%M  %Y-%m-%d\" --remember --remember-session --asterisks --greeting \"welcome to NixOS\" --cmd ${pkgs.niri}/bin/niri-session";
            user = "greeter";
          };
        };
      };
      # 登录时解锁 GPG keyring
      security.pam.services.greetd.enableGnomeKeyring = true;
    };
}
