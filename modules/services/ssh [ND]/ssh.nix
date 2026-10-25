{
  config,
  ...
}:
let
  mainUserName = config.flake.meta.mainUserName;
in
{
  flake.modules.nixos.ssh =
    { ... }:
    {
      services.openssh = {
        enable = true;
        openFirewall = false;
        settings = {
          PasswordAuthentication = true;
          KbdInteractiveAuthentication = false;
          PermitRootLogin = "no";
          MaxAuthTries = 3;
          LoginGraceTime = 30;
          ClientAliveInterval = 300;
          ClientAliveCountMax = 2;
          AllowUsers = [ mainUserName ];
        };
      };

      services.fail2ban = {
        enable = true;
        maxretry = 3;
        bantime = "1h";
      };
    };

  flake.modules.darwin.ssh = {
    services.openssh = {
      enable = true;
      extraConfig = ''
        PasswordAuthentication yes
        KbdInteractiveAuthentication no
        PermitRootLogin no
        MaxAuthTries 3
      '';
    };
  };
}
