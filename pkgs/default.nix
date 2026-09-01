{
  inputs,
  pkgs,
  ...
}:
let
  inherit (inputs) nixpak;

  # wrapper 函数
  wrapper =
    prev: path:
    let
      pkgs = prev;
      inherit (pkgs) lib;
    in
    pkgs.callPackage path {
      mkNixPak = nixpak.lib.nixpak {
        inherit pkgs;
        inherit lib;
      };
      mkAppWrapper =
        package:
        {
          binPath ? "bin/${baseNameOf (lib.getExe package)}",
          prefixPathes ? with pkgs; [ flatpak-xdg-utils ],
          prefixLibraries ? with pkgs; [ libx11 ],
          extraWrapperArgs ? [ ],
        }:
        let
          mainProgram = baseNameOf binPath;
          prefixPathesArg = lib.optionals (builtins.length prefixPathes > 0) [
            "--prefix"
            "PATH"
            ":"
            "${lib.makeBinPath prefixPathes}"
          ];
          prefixLibrariesArg = lib.optionals (builtins.length prefixLibraries > 0) [
            "--prefix"
            "LD_LIBRARY_PATH"
            ":"
            "${lib.makeLibraryPath prefixLibraries}"
          ];
          makeWrapperArgs = prefixPathesArg ++ prefixLibrariesArg ++ extraWrapperArgs;
        in
        (pkgs.runCommandLocal "nixpak-app-wrapper-${mainProgram}"
          {
            inherit (package) passthru;
            nativeBuildInputs = [ pkgs.makeWrapper ];
            meta = { inherit mainProgram; };
          }
          ''makeWrapper '${package}/${binPath}' "$out/bin/${mainProgram}" ${lib.escapeShellArgs makeWrapperArgs}''
        );
    };
in
{
  # 非 nixpak 包
  # _2048 = pkgs.callPackage ./apps/2048 { };
  # maple-mono-custom = pkgs.callPackage ./apps/maple-mono { inherit inputs; };
  asuka-fonts = pkgs.callPackage ./apps/asuka-fonts { };
  win11-fonts = pkgs.callPackage ./apps/microsoft-fonts { };
  harmonyos-sans = pkgs.callPackage ./apps/harmonyos-sans { };
  # mark-shot = pkgs.callPackage ./apps/mark-shot { };
  # fooyin = pkgs.callPackage ./apps/fooyin { };
  splayer-next = pkgs.callPackage ./apps/splayer-next { };
  # 备选打包方案：nixpkgs electron 运行时版（同目录 electron.nix），与 .deb 直解版对比用
  splayer-next-electron = pkgs.callPackage ./apps/splayer-next/electron.nix { };

  # nixpak 沙箱包装包
  nixpaks = {
    qq = wrapper pkgs ./nixpaks/qq.nix;
    wechat = wrapper pkgs ./nixpaks/wechat.nix;
    # feishu = wrapper pkgs ./nixpaks/feishu.nix;
    # telegram = wrapper pkgs ./nixpaks/telegram.nix;
    # spotify = wrapper pkgs ./nixpaks/spotify.nix;
    # wemeet = wrapper pkgs ./nixpaks/wemeet.nix;
    # wpsoffice = wrapper pkgs ./nixpaks/wpsoffice.nix;
  };
}
