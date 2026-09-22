{
  flake.modules.homeManager.rime-user-overrides =
    {
      lib,
      ...
    }:
    {
      # rime sync 需要备份这些文件，所以不能用 xdg.dataFile（创建只读符号链接）
      # 每次 rebuild 都会覆盖
      home.activation.rime-custom-yaml = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        install -D -m 644 ${./default.custom.yaml} ~/.local/share/fcitx5/rime/default.custom.yaml
        install -D -m 644 ${./wanxiang.custom.yaml} ~/.local/share/fcitx5/rime/wanxiang.custom.yaml
      '';
    };
}
