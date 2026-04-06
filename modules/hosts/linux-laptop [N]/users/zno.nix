{
  inputs,
  self,
  ...
}:
{
  flake.modules.nixos.linux-laptop =
    { config, ... }:
    {
      imports =
        with inputs.self.modules.nixos;
        with inputs.self.factory;
        [
          zno
        ];

      # ...

      home-manager.users.zno = {
        ###

      };
    };
}
