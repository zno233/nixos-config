{
  stdenv,
  python3,
  fetchPypi,
  inputs,
}:
let
  py = python3;
  pypkgs = py.pkgs;

  ufo-extractor = pypkgs.buildPythonPackage rec {
    pname = "ufo_extractor";
    version = "0.8.1";
    format = "pyproject";
    src = fetchPypi {
      inherit pname version;
      extension = "zip";
      sha256 = "sha256-5MK6NFjcwO4gOjoW2Ibzc25Qw2taTpBrl+XcxIbhhj0=";
    };
    build-system = with pypkgs; [
      setuptools
      setuptools-scm
    ];
    propagatedBuildInputs = with pypkgs; [
      fonttools
      fontfeatures
    ];
    doCheck = false;
  };

  foundrytools = pypkgs.buildPythonPackage rec {
    pname = "foundrytools";
    version = "0.1.4";
    format = "setuptools";
    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-pWHSIhj0g1jUs6ij5o2NGcDBrgJDBCXjQyJmSpYOxfo=";
    };
    propagatedBuildInputs = with pypkgs; [
      afdko
      cffsubr
      defcon
      dehinter
      fonttools
      setuptools
      ttfautohint-py
      ufo-extractor
      ufo2ft
      ufolib2
    ];
    doCheck = false;
  };

  foundrytools-cli = pypkgs.buildPythonPackage rec {
    pname = "foundrytools_cli";
    version = "2.0.3";
    format = "pyproject";
    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-d5fVfBlOOfTGyYnsYOwXRF9AG8bB55bAmjfRnXsvPbs=";
    };
    build-system = [ pypkgs.hatchling ];
    propagatedBuildInputs = with pypkgs; [
      foundrytools
      click
      loguru
      pathvalidate
      afdko
      rich
      fonttools
      ufolib2
    ];
    doCheck = false;
  };
in
stdenv.mkDerivation {
  pname = "maple-mono-custom";
  version = "v7.9";
  src = inputs.maple-mono;

  nativeBuildInputs = [
    py
  ]
  ++ (with pypkgs; [
    # 统一使用 pypkgs 确保版本对齐
    fonttools
    glyphslib
    lxml
    cffsubr
    cu2qu
    defcon
    ttfautohint-py
    foundrytools-cli
  ]);

  buildPhase = ''
    python build.py --no-nerd-font --feat cv66,ss05 --remove-tag-liga --ttf-only
  '';

  installPhase = ''
    mkdir -p $out/share/fonts/truetype
    cp -a fonts/TTF-AutoHint $out/share/fonts/truetype/
  '';
}
