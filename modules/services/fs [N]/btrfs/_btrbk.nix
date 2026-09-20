{
  flake.modules.nixos.btrbk =
    {
      config,
      pkgs,
      ...
    }:
    {
      services.btrbk.instances.home-snapshots = {
        onCalendar = "hourly"; # 每小时一次，或者改为 "daily"
        settings = {
          snapshot_preserve_min = "2d"; # 至少保留2天
          snapshot_preserve = "14d"; # 保留14天内的快照

          # 定义备份源
          volume."/" = {
            snapshot_dir = ".snapshots"; # 快照存放在 /.snapshots (root 子卷内)
            subvolume."home" = { };
          };
        };
      };
      # Btrbk does not create snapshot directories automatically, so create one here.
      systemd.tmpfiles.rules = [
        "d .snapshots 0755 root root"
      ];
    };
}
