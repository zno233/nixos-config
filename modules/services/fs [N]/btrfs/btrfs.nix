{
  inputs,
  ...
}:
{
  flake.modules.nixos.btrfs =
    {
      config,
      pkgs,
      ...
    }:
    {
      # imports = with inputs.self.modules.nixos; [
      #   btrbk
      # ];

      # Btrfs 自动动态回收（对所有 Btrfs 文件系统生效）
      systemd.services.btrfs-auto-reclaim = {
        description = "Enable Btrfs dynamic_reclaim + periodic_reclaim";
        wantedBy = [ "multi-user.target" ];
        after = [ "local-fs.target" ];

        script = ''
          echo "=== Enabling Btrfs auto reclaim on all filesystems ==="
          shopt -s nullglob
          for dir in /sys/fs/btrfs/*-*/allocation/data; do
            if [ -d "$dir" ]; then
              uuid=$(basename "$(dirname "$(dirname "$dir")")")
              echo "Enabling on UUID: $uuid"
              echo 1 > "$dir/dynamic_reclaim"   2>/dev/null || echo "Warning: Failed dynamic_reclaim on $uuid"
              echo 1 > "$dir/periodic_reclaim"  2>/dev/null || echo "Warning: Failed periodic_reclaim on $uuid"
            fi
          done
          echo "Btrfs auto reclaim setup completed."
        '';

        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ProtectSystem = "strict";
          ReadWritePaths = [ "/sys/fs/btrfs" ];
          User = "root";
        };
      };

      # 自动 Scrub（数据校验）
      services.btrfs.autoScrub = {
        enable = true;
        interval = "monthly";
        fileSystems = [ "/" ];
      };
    };
}
