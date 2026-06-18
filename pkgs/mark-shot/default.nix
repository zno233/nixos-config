{
  pkgs ? import <nixpkgs> { },
}:
let
  rapidocrPython = pkgs.python3.withPackages (ps: [
    ps.rapidocr-onnxruntime
  ]);
in
pkgs.stdenv.mkDerivation {
  pname = "mark-shot";
  version = "0.1.29";
  src = pkgs.fetchFromGitHub {
    owner = "jswysnemc";
    repo = "mark-shot";
    rev = "main";
    hash = "sha256-OyCBIksDZheXC4ARDOVmlwhUKIHGRJThRWHOICmg4YY="; # 替换为真实 hash
  };
  nativeBuildInputs = with pkgs; [
    cmake
    pkg-config
    qt6.wrapQtAppsHook
  ];
  buildInputs = with pkgs; [
    qt6.qtbase
    qt6.qtwayland
    qt6.qtsvg
    pipewire
    libportal
    libX11
    libxcb
    kdePackages.layer-shell-qt
    grim
    wl-clipboard
    rapidocrPython
  ];
  cmakeFlags = [
    "-DMARK_SHOT_WITH_LAYER_SHELL=ON"
    "-DMARK_SHOT_WITH_LIBPORTAL=ON"
  ];
  preFixup = ''
    wrapQtApp "$out/bin/mark-shot" \
      --prefix PATH : ${
        pkgs.lib.makeBinPath [
          pkgs.grim
          pkgs.wl-clipboard
        ]
      }

    wrapProgram "$out/bin/mark-shot-ocr" \
      --prefix PATH : ${rapidocrPython}/bin
  '';
  meta = with pkgs.lib; {
    description = "Screenshot and annotation tool";
    homepage = "https://github.com/jswysnemc/mark-shot";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
