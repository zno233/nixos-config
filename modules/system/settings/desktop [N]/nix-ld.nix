{
  flake.modules.nixos.nix-ld =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      programs.nix-ld = {
        enable = true;
        libraries = with pkgs; [
          stdenv.cc.cc.lib #  libstdc++.so.6 等 C++ 运行时
          zlib # 压缩库
          openssl # 加密/网络
          udev # 设备管理
          alsa-lib # 音频基础
          libGL # OpenGL 图形
          vulkan-loader # Vulkan
        ];
      };
    };
}
