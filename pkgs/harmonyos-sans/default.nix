{ stdenvNoCC, fetchFromGitHub }:

stdenvNoCC.mkDerivation {
  pname = "harmonyos-sans";
  version = "1.0";

  src = fetchFromGitHub {
    owner = "zhiyuan1i";
    repo = "fonts-harmonyos-sans-cn";
    rev = "main";
    hash = "sha256-AzTBibviknpxkC+TBcQtU4LC3ol6tt+M80K+OTtms8I="; # 第一次运行会报错，届时替换
  };

  installPhase = ''
    mkdir -p $out/share/fonts/truetype/harmonyos-sans
    cp source/usr/share/fonts/truetype/harmonyos-sans/*.ttf $out/share/fonts/truetype/harmonyos-sans/
  '';
}