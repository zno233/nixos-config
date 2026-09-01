{
  flake.modules.nixos.game-performance =
    {
      pkgs,
      ...
    }:
    let
      game-performance = pkgs.writeShellApplication {
        name = "game-performance";

        runtimeInputs = with pkgs; [
          tuned
          scx-loader
          systemd
        ];

        text = ''
          set -euo pipefail

          if [[ $# -eq 0 ]]; then
            echo "Usage: game-performance <command> [args...]" >&2
            exit 2
          fi

          # --------------------------------------------------------
          # 保存当前 TuneD profile
          # --------------------------------------------------------
          previous_profile="$(
            tuned-adm active |
            sed -n 's/^Current active profile:[[:space:]]*//p'
          )"

          restore() {
            echo "game-performance: restoring system state..." >&2

            # 恢复 scx_loader 配置中的默认 scheduler + mode
            scxctl restore >/dev/null 2>&1 || true

            # 恢复游戏启动前的 TuneD profile
            if [[ -n "$previous_profile" ]]; then
              tuned-adm profile "$previous_profile" \
                >/dev/null 2>&1 || true
            fi
          }

          trap restore EXIT INT TERM

          # --------------------------------------------------------
          # TuneD：进入性能 profile
          # 你的配置：
          #
          # PPD performance → latency-performance
          # --------------------------------------------------------
          if ! tuned-adm profile latency-performance; then
            echo \
              "game-performance: failed to switch TuneD profile" >&2
            exit 1
          fi

          # --------------------------------------------------------
          # SCX：对当前运行中的 scheduler 切换到 Gaming mode
          #
          # 不指定 --sched：
          #   bpfland → bpfland Gaming
          #   lavd    → lavd Gaming
          #   cake    → cake Gaming
          # --------------------------------------------------------
          if ! scxctl switch --mode gaming; then
            echo \
              "game-performance: current scheduler has no usable Gaming mode" \
              >&2
            exit 1
          fi

          # --------------------------------------------------------
          # 防止系统在游戏期间 idle / sleep
          # --------------------------------------------------------
          systemd-inhibit \
            --what=idle:sleep \
            --who="game-performance" \
            --why="Game is running" \
            --mode=block \
            -- "$@"
        '';
      };
    in
    {
      environment.systemPackages = [
        game-performance
      ];
    };
}
