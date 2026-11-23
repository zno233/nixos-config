{
  flake.modules.nixos.plasma =
    {
      lib,
      pkgs,
      ...
    }:
    let
      plasma = pkgs.kdePackages.plasma-workspace;

      # greetd 不提供 XDG_SESSION_ID 和指向 systemd 用户管理器的
      # DBUS_SESSION_BUS_ADDRESS。KWin 靠前者去 logind 找自己的 session，
      # 缺失就不走 TakeDevice，直接打开 /dev/dri/card0 失败 → 没有 output → 黑屏。
      startPlasma = pkgs.writeShellScript "startplasma-greetd" ''
        export PATH=${
          lib.makeBinPath (
            with pkgs;
            [
              systemd
              coreutils
              gnused
              gnugrep
            ]
          )
        }:$PATH

        : "''${XDG_RUNTIME_DIR:=/run/user/$(id -u)}"
        export XDG_RUNTIME_DIR

        # 从 systemd 用户管理器抄一份真正的 XDG_SESSION_ID，最多等 10s
        if [ -z "''${XDG_SESSION_ID:-}" ]; then
          for _ in $(seq 1 100); do
            XDG_SESSION_ID="$(systemctl --user show-environment 2>/dev/null \
              | sed -n 's/^XDG_SESSION_ID=//p' | head -n1)"
            [ -n "$XDG_SESSION_ID" ] && break
            sleep 0.1
          done
          export XDG_SESSION_ID
        fi

        export XDG_SESSION_TYPE=wayland
        export XDG_CURRENT_DESKTOP=KDE
        export XDG_SESSION_DESKTOP=KDE
        : "''${XDG_SEAT:=seat0}"
        export XDG_SEAT
        : "''${DBUS_SESSION_BUS_ADDRESS:=unix:path=$XDG_RUNTIME_DIR/bus}"
        export DBUS_SESSION_BUS_ADDRESS

        # logind 先把 session 标成 active，否则 TakeDevice 返回 EACCES
        if [ -n "''${XDG_SESSION_ID:-}" ]; then
          for _ in $(seq 1 50); do
            active="$(loginctl show-session "$XDG_SESSION_ID" -p Active --value 2>/dev/null || true)"
            [ "$active" = yes ] && break
            sleep 0.2
          done
        fi

        # KWin 未实现 zwp_input_method_v2，fcitx5 的 waylandFrontend 在此接不到
        # 客户端，故走 IM 模块
        export GTK_IM_MODULE=fcitx
        export QT_IM_MODULE=fcitx
        export XMODIFIERS=@im=fcitx

        # stylix 全局设了 QT_QPA_PLATFORMTHEME=qt5ct，会连带加载
        # libqxdgdesktopportal.so，它在事件循环前同步调用
        # portal.Settings.ReadAll（25s 超时），与等待 graphical-session.target
        # 的 xdg-desktop-portal 互等，登录因此拖到 60~90s。指定 kde 只加载
        # KDEPlasmaPlatformTheme6.so，不发该请求。
        # QT_STYLE_OVERRIDE=kvantum 会与 plasma-integration 叠加成双重主题化。
        export QT_QPA_PLATFORMTHEME=kde
        unset QT_STYLE_OVERRIDE

        # portal 后端由 D-Bus 激活并继承管理器环境，管理器侧也要一致。
        # QT_STYLE_OVERRIDE 出自 environment.d，只能用空值覆盖（Qt 视空串为未设置）。
        systemctl --user set-environment QT_QPA_PLATFORMTHEME=kde 2>/dev/null || true
        systemctl --user set-environment QT_STYLE_OVERRIDE= 2>/dev/null || true

        systemctl --user import-environment \
          XDG_SESSION_ID XDG_SESSION_TYPE XDG_CURRENT_DESKTOP \
          XDG_SESSION_DESKTOP XDG_SEAT XDG_VTNR \
          GTK_IM_MODULE QT_IM_MODULE XMODIFIERS QT_QPA_PLATFORMTHEME 2>/dev/null || true

        # greetd 把会话 stdio 接在 VT 上，日志只写文件，免得登录时刷屏
        diag="''${XDG_RUNTIME_DIR:-/tmp}/plasma-session-env.log"
        {
          echo "== plasma wayland session (greetd wrapper) =="
          env | grep -E '^(XDG_|DBUS_|WAYLAND_|QT_|KDE)' | sort
        } > "$diag" 2>&1 || true

        exec ${plasma}/libexec/plasma-dbus-run-session-if-needed ${plasma}/bin/startplasma-wayland
      '';

      # 顶掉 plasma-workspace 自带的 plasma.desktop，让 greeter 跑上面的 wrapper。
      # installedSessions 按 sessionPackages 顺序链接、先到先得，配 mkBefore 生效。
      plasmaSession =
        pkgs.runCommand "plasma-wayland-greetd-session"
          {
            providedSessions = [ "plasma" ];
            preferLocalBuild = true;
          }
          ''
            mkdir -p "$out/share/wayland-sessions"
            {
              echo '[Desktop Entry]'
              echo 'Type=Application'
              echo 'Name=Plasma (Wayland)'
              echo 'Comment=Plasma by KDE'
              echo 'Exec=${startPlasma}'
              echo 'TryExec=${plasma}/bin/startplasma-wayland'
              echo 'DesktopNames=KDE'
            } > "$out/share/wayland-sessions/plasma.desktop"
          '';
    in
    {
      # 只装桌面本体，KDE 应用由下面的 excludePackages 排除
      services.desktopManager.plasma6.enable = true;

      # plasma6 默认打开 KDE PIM（kmail / kontact / merkuro + akonadi 全家桶），
      # 不用邮件则关掉，可省掉 akonadi_control 等常驻进程
      programs.kde-pim.enable = false;

      # 与 niri.nix / umbriel.nix 同构。默认 Secret 给 kwallet，而 niri 走
      # gnome-keyring；Chromium 靠 portal.Secret 取 cookie 密钥，换钥匙串就解不开
      # 旧 cookie，切换会话会全员掉登录，故 Plasma 也用 gnome-keyring。
      # xdg.portal.config.kde = {
      #   default = "kde";
      #   "org.freedesktop.impl.portal.Settings" = "kde;gtk;";
      #   "org.freedesktop.impl.portal.Secret" = "gnome-keyring";
      #   "org.freedesktop.impl.portal.Notification" = "plasmanotify";
      # };

      # 让 greeter 用 wrapper 版的 Plasma session
      services.displayManager.sessionPackages = lib.mkBefore [ plasmaSession ];

      # 对应 plasma6.nix 的 optionalPackages，按「只要桌面」裁剪。
      # 别动 requiredPackages（kwin、plasma-workspace、kscreen、kscreenlocker、
      # plasma-nm、plasma-pa、powerdevil、bluedevil、breeze、polkit-kde-agent-1、
      # xdg-desktop-portal-kde、kio …），否则桌面起不来。
      environment.plasma6.excludePackages = with pkgs.kdePackages; [
        # 终端 / 编辑器 / 文件管理
        konsole
        kate
        ktexteditor # 仅供 kate 提权使用
        dolphin
        dolphin-plugins
        baloo-widgets # Dolphin 信息面板的 baloo 集成

        # 独立应用
        ark
        elisa
        gwenview
        okular
        spectacle
        ffmpegthumbs # 视频缩略图，供文件预览
        khelpcenter

        # 浏览器集成
        plasma-browser-integration
      ];
    };
}
