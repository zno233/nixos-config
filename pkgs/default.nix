{
  inputs,
  pkgs,
  ...
}:
{
  # _2048 = pkgs.callPackage ./2048 { };
  # maple-mono-custom = pkgs.callPackage ./maple-mono { inherit inputs; };
  win11-fonts = pkgs.callPackage ./microsoft-fonts { };
  harmonyos-sans = pkgs.callPackage ./harmonyos-sans { };
  # mark-shot = pkgs.callPackage ./mark-shot { };
  # fooyin = pkgs.callPackage ./fooyin { };
  splayer-next = pkgs.callPackage ./splayer-next { };
  # 备选打包方案：nixpkgs electron 运行时版（同目录 electron.nix），与 .deb 直解版对比用
  splayer-next-electron = pkgs.callPackage ./splayer-next/electron.nix { };
}
