{
  flake.modules.nixos.distrobox =
    { config, pkgs, ... }:
    {
      virtualisation.podman = {
        enable = true;
        dockerCompat = true; # 让 docker 命令也能用
        defaultNetwork.settings.dns_enabled = true;
      };

      # rootless 必备（让容器用你的 UID/GID 运行，无 sudo）
      users.users."zno" = {
        subUidRanges = [
          {
            startUid = 100000;
            count = 65536;
          }
        ];
        subGidRanges = [
          {
            startGid = 100000;
            count = 65536;
          }
        ];
      };

      environment.systemPackages = with pkgs; [ distrobox ];
    };
}
