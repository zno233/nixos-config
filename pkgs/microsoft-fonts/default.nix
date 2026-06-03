{ stdenvNoCC, fetchFromGitHub }:

stdenvNoCC.mkDerivation {
  pname = "win11-fonts";
  version = "1.0";

  src = fetchFromGitHub {
    owner = "pjobson";
    repo = "Microsoft-Fonts";
    rev = "main";
    # 第一次运行会报错，届时替换为终端输出的真实哈希
    hash = "sha256-KeCVN5q0MGKMJHeqaI3Oyb5/6bNjGC33s0Gv9gqS2Yk=";
  };

  installPhase = ''
    # 创建目标字体目录
    mkdir -p $out/share/fonts/truetype
    
    # 进入包含 .gz 文件的目录
    cd "2021 - Windows 11/ttf"
    
    # 查找所有 .gz 文件并解压到目标目录
    for f in *.gz; do
      gunzip -c "$f" > "$out/share/fonts/truetype/$(basename "$f" .gz)"
    done
  '';
}