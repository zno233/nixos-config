{
  lib,
  stdenvNoCC,
  fetchurl,
}:

let
  version = "0.1.5";
  baseUrl = "https://github.com/zno233/asuka-fonts/releases/download/v${version}";

  fonts = [
    # Asuka Mono (等宽 — 终端/代码)
    {
      name = "AsukaMono-Light.ttf";
      hash = "sha256-hEuUSI/5BeIp40yW2Jdk+eFMZzOxyBuIYSkXjEtaJUY=";
    }
    {
      name = "AsukaMono-Regular.ttf";
      hash = "sha256-2KoQPhUe++J4d3gsYB0zPILw9LZElgEg2DQZ9orSFU4=";
    }
    {
      name = "AsukaMono-Bold.ttf";
      hash = "sha256-eM/y1eLXQAb2zwysnma9XOSPADnhUQxG4xy1XVgBlDQ=";
    }
    # Asuka Sans (比例 — 阅读/文档)
    {
      name = "AsukaSans-Light.ttf";
      hash = "sha256-NH8mlURsm8Dwz7+0I73jC8UPMXFcM40bxJikX71uKyI=";
    }
    {
      name = "AsukaSans-Regular.ttf";
      hash = "sha256-qyLLZCbKZiE8ZdQZemzTepTp3LWvjzgxu7l7wxJcK20=";
    }
    {
      name = "AsukaSans-Bold.ttf";
      hash = "sha256-dbyPFkD/miApTFwcDn3LRbJYTGKmbUrxk+ApqLydvy0=";
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
