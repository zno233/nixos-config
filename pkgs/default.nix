{
  inputs,
  pkgs,
  ...
}:
{
  # _2048 = pkgs.callPackage ./2048 { };
  maple-mono-custom = pkgs.callPackage ./maple-mono { inherit inputs; };
  win11-fonts = pkgs.callPackage ./microsoft-fonts { };
  harmonyos-sans = pkgs.callPackage ./harmonyos-sans { };
  mark-shot = pkgs.callPackage ./mark-shot { };
  fooyin = pkgs.callPackage ./fooyin { };
}
