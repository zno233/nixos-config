{
  inputs,
  ...
}:
{
  flake-file.inputs = {
    mark-shot = {
      url = "github:jswysnemc/mark-shot";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.modules.homeManager.mark-shot =
    { pkgs, ... }:
    let
      markShot = inputs.mark-shot.packages.${pkgs.stdenv.hostPlatform.system}.default;

      # 扫码 / OCR helper 使用的解释器：自带 zxing-cpp 与 rapidocr 后端，
      helperPython = pkgs.python3.withPackages (
        ps: with ps; [
          zxing-cpp
          pillow
          rapidocr-onnxruntime
        ]
      );
    in
    {
      home.packages = [
        (pkgs.symlinkJoin {
          name = "mark-shot";
          paths = [ markShot ];
          nativeBuildInputs = [ pkgs.makeWrapper ];
          # config.json 的 env 段优先级更高，
          # 因此需删除 ~/.config/mark-shot/config.json 中同名键才能以此处为准。
          postBuild = ''
            wrapProgram "$out/bin/mark-shot" \
              --set MARK_SHOT_CODE_SCAN_PYTHON ${helperPython}/bin/python3 \
              --set MARK_SHOT_OCR_PYTHON ${helperPython}/bin/python3
          '';
        })
      ];
    };
}
