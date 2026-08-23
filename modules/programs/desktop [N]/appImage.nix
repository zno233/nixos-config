{
  flake.modules.nixos.appImage =
    { ... }:
    {
      programs.appimage.enable = true;
      programs.appimage.binfmt = true;
    };
}
