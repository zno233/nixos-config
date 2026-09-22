{
  inputs,
  ...
}:
{
  flake.modules.nixos.linux-desktop =
    {
      config,
      ...
    }:
    {
      imports =
        with inputs.self.modules.nixos;
        with inputs.self.factory;
        [
          zno
          (mount-cifs-nixos {
            host = "home-server.lan";
            resource = "home";
            destination = "/home/users/zno/homeserver";
            credentialspath = "${config.age.secrets."homeserver-cred".path}";
            UID = "zno";
            GID = "users";
          })
        ];

      age.secrets."homeserver-cred" = {
        file = "${inputs.secrets}/homeserver-cred.age";
      };

      # ...

      home-manager.users.zno = {
        ###
      };
    };
}
