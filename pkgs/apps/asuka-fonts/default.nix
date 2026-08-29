{
  lib,
  stdenvNoCC,
  fetchurl,
}:

let
  version = "0.1.1";
  baseUrl = "https://github.com/zno233/asuka-fonts/releases/download/v${version}";

  fonts = [
    # Asuka Mono (等宽 — 终端/代码)
    {
      name = "AsukaMono-Light.ttf";
      hash = "sha256-y1R0W37T7LBzHe98xpPBdcMu7uwRg8DUrMM06iZzr6E=";
    }
    {
      name = "AsukaMono-Regular.ttf";
      hash = "sha256-RR+F+knZUjR7CUdsZkuN1Dt3o22aNKQZNnFC61jKDfc=";
    }
    {
      name = "AsukaMono-Bold.ttf";
      hash = "sha256-Vk+cLsCvpy/XGGznQQuj2maWKspMGBw0ABS9M4R6GuY=";
    }
    # Asuka Sans (比例 — 阅读/文档)
    {
      name = "AsukaSans-Light.ttf";
      hash = "sha256-9pnNmrMtGL5IYx2blSoPypRmUz316pkwUq1lmqTlwss=";
    }
    {
      name = "AsukaSans-Regular.ttf";
      hash = "sha256-c8O48pKsaIRxpmgzKl7lZSGMXLLpOT6wYUshEL3pNq4=";
    }
    {
      name = "AsukaSans-Bold.ttf";
      hash = "sha256-8uRNmUEFf3B69iDZEDQJoJEqz/phrZI76EFzvfDrz0Q=";
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
    description = "Iosevka-based font with Nerd Font icons and CJK support";
    homepage = "https://github.com/zno233/asuka-fonts";
    license = with licenses; [
      ofl11 # Iosevka, Noto Sans CJK
      mit # Nerd Fonts
    ];
    platforms = platforms.all;
  };
}
