{
  inputs,
  ...
}:
{
  flake.modules.nixos.others = {
    imports = with inputs.self.modules.nixos; [
      system-program
    ];
  };

  flake.modules.homeManager.others = {
    imports = with inputs.self.modules.homeManager; [
      rime-user-overrides
    ];
  };
}
