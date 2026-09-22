{
  inputs,
  ...
}:
{
  flake.modules.nixos.linux-laptop = {
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
