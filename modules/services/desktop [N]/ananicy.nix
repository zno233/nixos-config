{
  flake.modules.nixos.ananicy =
    {
      pkgs,
      ...
    }:
    {
      services.ananicy = {
        enable = true;

        package = pkgs.ananicy-cpp;

        rulesProvider = pkgs.ananicy-rules-cachyos;

        settings = {
          cgroup_load = true;
          type_load = true;
          rule_load = true;

          # CPU scheduling
          apply_nice = true;
          apply_latnice = true;
          apply_sched = true;

          # I/O
          apply_ioclass = true;
          apply_ionice = true;

          # Memory pressure
          apply_oom_score_adj = true;

          # CachyOS CPUQuota cgroups
          apply_cgroup = true;
        };

        extraRules = [
          # Background compilers:
          # give bpfland enough information to keep them below
          # interactive/game workloads without crippling build time.
          # {
          #   name = "rustc";
          #   nice = 9;
          #   sched = "batch";
          #   ioclass = "idle";
          # }
        ];
      };

      # NixOS 26.11/unstable currently has a cgroup-v2 startup
      # ordering issue where ananicy-cpp may start before the
      # CPU controller is available.
      #
      # Remove this workaround once the upstream issue is fixed.
      systemd.services.ananicy-cpp.serviceConfig.ExecStartPre =
        let
          enableCpuController = pkgs.writeShellScript "ananicy-cpp-enable-cgroup-cpu" ''
            echo +cpu > /sys/fs/cgroup/cgroup.subtree_control
          '';
        in
        [ "${enableCpuController}" ];
    };
}
