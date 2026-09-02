{
  lib,
  stdenvNoCC,
  fetchurl,
}:

let
  version = "0.1.3";
  baseUrl = "https://github.com/zno233/asuka-fonts/releases/download/v${version}";

  fonts = [
    # Asuka Mono (等宽 — 终端/代码)
    {
      name = "AsukaMono-Light.ttf";
      hash = "sha256-5nfiGncrGe0K+gRtWTYnImJkv4WtXFVbN+lLDMHwTs0=";
    }
    {
      name = "AsukaMono-Regular.ttf";
      hash = "sha256-K/ZsXDicGvzFfm2NDXG1URN+gWDqfeu/djznEEnbVCQ=";
    }
    {
      name = "AsukaMono-Bold.ttf";
      hash = "sha256-QxNcxnBHJZVRfAatURLQVrDi9UoYkKHXWrMCZuJyD2Y=";
    }
    # Asuka Sans (比例 — 阅读/文档)
    {
      name = "AsukaSans-Light.ttf";
      hash = "sha256-Enl2UgUFBk6IkTXOf4Da1SDLr3sMkb7KM47C+IaUVz0=";
    }
    {
      name = "AsukaSans-Regular.ttf";
      hash = "sha256-9ycwUUiH9m9gbG54CNTUE4iBwfAldLsBaa/1iG8LQac=";
    }
    {
      name = "AsukaSans-Bold.ttf";
      hash = "sha256-3IJPTfonDIW/kFgAvKdI7zrwijn9y+nCmHsYJI54RFY=";
    }
  ];
in
stdenvNoCC.mkDerivation {
  pname = "asuka-fonts";
  inherit version;

  srcs = map (
    font:
    fetchurl {
      url = "${baseUrl}/${font.name}";
      pname = font.name;
      inherit (font) hash;
    }
  ) fonts;

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/fonts/truetype

    for src in $srcs; do
      install -Dm644 "$src" "$out/share/fonts/truetype/$(basename "$src")"
    done

    runHook postInstall
  '';

  meta = with lib; {
    description = "Iosevka-based font with Nerd Font icons and non-Latin character support";
    homepage = "https://github.com/zno233/asuka-fonts";
    license = with licenses; [
      ofl11 # Iosevka, LXGW WenKai, WenYuan Rounded
      mit # Nerd Fonts
    ];
    platforms = platforms.all;
  };
}
