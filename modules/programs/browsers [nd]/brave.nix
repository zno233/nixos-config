{ inputs, lib, ... }:
{
  flake.modules.nixos.brave =
    { ... }:
    let
      # 带注释的 policies（toJSON 会自动生成纯 JSON）
      bravePolicies = {
        # --- 核心隐私与安全 ---
        BrowserSignin = 0; # 禁用登录，保护隐私
        SyncDisabled = true; # 彻底禁用同步引擎
        MetricsReportingEnabled = false; # 禁用指标上报
        BackgroundModeEnabled = false; # 关闭浏览器后立即释放所有进程

        # 遥测/诊断关闭
        BraveStatsPingEnabled = false; # 每日使用量 ping
        UserFeedbackAllowed = false; # 禁用用户反馈邀请
        FeedbackSurveysEnabled = false; # 禁用反馈调查
        SafeBrowsingExtendedReportingEnabled = false; # 禁用扩展安全报告（不向 Google 上报可疑 URL；基础 Safe Browsing 仍开启）
        TranslateEnabled = false; # 禁用翻译（减少功能面；如需翻译改回 true）
        SpellCheckServiceEnabled = false; # 禁用拼写检查网络服务（输入内容不发送；本地词典拼写仍可用）

        # --- Brave 专属彻底 debloat ---
        BraveAIChatEnabled = false; # 禁用 Leo AI（1.6x+ 起 Leo 助手已并入，无独立 policy）
        BraveWalletDisabled = true; # 禁用数字钱包 + Web3
        BraveRewardsDisabled = true; # 禁用 Rewards / BAT / 隐私广告
        BraveVPNDisabled = true; # 禁用 VPN
        BraveP3AEnabled = false; # 禁用匿名统计（P3A）
        BraveTalkDisabled = true; # 禁用 Brave Talk（视频会议）
        BraveNewsDisabled = true; # 禁用新标签页新闻流
        # BravePlaylistEnabled = false; # 禁用 Playlist
        BraveSpeedreaderEnabled = false; # 禁用快速阅读
        BraveWaybackMachineEnabled = false; # 禁用 Wayback Machine 集成
        BraveWebDiscoveryEnabled = false; # 禁用 Web Discovery 数据收集
        TorDisabled = true; # 禁用 Tor 窗口

        # 隐私增强（而非禁用）
        BraveDeAmpEnabled = true; # 剥离 AMP 重定向
        BraveDebouncingEnabled = true; # 剥离跟踪跳转
        BraveReduceLanguageEnabled = true; # 减少语言指纹（请求头）
        DefaultBraveFingerprintingV2Setting = 3; # 指纹防护锁定为标准（1=关闭，3=标准，无 2）

        # --- 禁用自动填充（交给 Bitwarden） ---
        AutofillAddressEnabled = false;
        AutofillCreditCardEnabled = false;
        PasswordManagerEnabled = false;

        # --- 网络隐私与连接 ---
        BuiltInDnsClientEnabled = false; # 使用系统 DNS
        AlternateErrorPagesEnabled = false; # 禁用纠错页面
        NetworkPredictionOptions = 1; # 禁用预连接/预取/预渲染（隐私优先：不泄露浏览意图、省流量；如重速度可改回 1）
        DefaultGeolocationSetting = 2; # 默认禁止地理位置（按站点手动授权）
        WebRtcIPHandling = "disable_non_proxied_udp"; # 限制 WebRTC IP 泄露
        HttpsUpgradesEnabled = true; # 强制 HTTPS 升级
        BlockThirdPartyCookies = true; # 阻止第三方 Cookie
        SearchSuggestEnabled = false; # 关闭搜索建议（避免按键泄漏给搜索服务）

        # --- 隐私增强（1.92+ 新增 policy） ---
        BraveGlobalPrivacyControlEnabled = true; # 全局隐私控制（GPC）：向站点发送"不要出售/共享"信号
        BraveTrackingQueryParametersFilteringEnabled = true; # 剥离 URL 中的追踪查询参数（utm_* 等）
        IPFSEnabled = false; # 禁用 IPFS 协议支持（弃用功能，减少网络面）

        # --- 易用性 ---
        ExternalProtocolDialogShowAlwaysOpenCheckbox = true;

        # --- Privacy Sandbox ---
        PrivacySandboxAdTopicsEnabled = false;
        PrivacySandboxAdMeasurementEnabled = false;
        PrivacySandboxSiteEnabledAdsEnabled = false;
        PrivacySandboxPromptEnabled = false;

        # --- 扩展管理（Policy 方式） ---
        ExtensionSettings = {
          "*" = {
            installation_mode = "allowed"; # 允许手动安装/开关
          };

          # 核心必需扩展（自动安装 + 锁定，无法关闭，确保始终可用）
          "nngceckbapebfimnlniiiahkandclblb" = {
            # Bitwarden
            installation_mode = "force_installed";
            update_url = "https://clients2.google.com/service/update2/crx";
          };
          "fnaicdffflnofjppbagibeoednhnbjhg" = {
            # Floccus（书签同步）
            installation_mode = "force_installed";
            update_url = "https://clients2.google.com/service/update2/crx";
          };
          "hfjbmagddngcpeloejdejnfgbamkjaeg" = {
            # Vimium C（键盘导航）
            installation_mode = "force_installed";
            update_url = "https://clients2.google.com/service/update2/crx";
          };

          # 辅助扩展：自动安装 + 可手动开关
          "bifgfhokfobhebifcogneljkpaaloonp" = {
            # Gesturefy（鼠标手势）
            installation_mode = "normal_installed";
            update_url = "https://clients2.google.com/service/update2/crx";
          };
          "jfedfbgedapdagkghmgibemcoggfppbb" = {
            # cat-catch
            installation_mode = "normal_installed";
            update_url = "https://clients2.google.com/service/update2/crx";
          };
          "mpkodccbngfoacfalldjimigbofkhgjn" = {
            # Aria2 Explorer
            installation_mode = "normal_installed";
            update_url = "https://clients2.google.com/service/update2/crx";
          };
          # "gcalenpjmijncebpfijmoaglllgpjagf" = {
          #   # Tampermonkey BETA
          #   installation_mode = "normal_installed";
          #   update_url = "https://clients2.google.com/service/update2/crx";
          # };
          "ndcooeababalnlpkfedmmbbbgkljhpjf" = {
            # scriptcat
            installation_mode = "normal_installed";
            update_url = "https://clients2.google.com/service/update2/crx";
          };
          # 其它未启用扩展
          # "mpiodijhokgodhhofbcjdecpffjipkle" # SingleFile
          # "bhchdcejhohfmigjafbampogmaanbfkg" # User-Agent Switcher and Manager
          # "iifacdnjakkhjjiengaffnegbndgingi" # Voyager
          # "cclelndahbckbenkjhflpdbgdldlbecc" # Get cookies.txt
          # "bbbiejemhfihiooipfcjmjmbfdmobobp" # BewlyBewly
          # "eaoelafamejbnggahofapllmfhlhajdd" # 小电视空降助手
          # "fjkmabmdepjfammlpliljpnbhleegehm" # WebRTC Control
          # "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin
        };
      };

    in
    {
      home-manager.sharedModules = [
        inputs.self.modules.homeManager.chromium
      ];

      # 系统级 policies
      environment.etc."brave/policies/managed/00-privacy-debloat.json".text =
        builtins.toJSON bravePolicies;
    };

  flake.modules.homeManager.chromium =
    { pkgs, ... }:
    {
      programs.chromium = {
        enable = true;
        package = pkgs.brave-origin;
        commandLineArgs = [
          # 1. 平台 + GPU 加速（仅保留 Linux 上非默认开启、需显式声明的项）
          # Chromium 120+ 默认 ozone auto（可自动检测 Wayland），理论上可省去此 flag；
          # 但 niri 为纯 Wayland 合成器（无 X server），auto 在异常启动环境（SSH/tmux/
          # 剥离 env 的 desktop entry）下会回退 X11 导致崩溃 → 显式钉死 Wayland，稳定性优先。
          "--ozone-platform=wayland"
          # kDefaultEnableGpuRasterization 在 Linux 上默认 DISABLED（仅 Apple/Win/CrOS/Android 默认开）
          # → --enable-gpu-rasterization 非冗余，保留
          "--enable-gpu-rasterization"
          # enable_zero_copy 无 finch 实验默认（DefaultEnableZeroCopy 已不存在），GpuPreferences 默认 false
          # → --enable-zero-copy 非冗余，保留（零拷贝光栅化，避免 CPU↔GPU 上传拷贝）
          "--enable-zero-copy"
          # Chromium 150+ 改名：VaapiVideoDecoder→AcceleratedVideoDecoder（Linux 默认开，不显式写出），
          # VaapiVideoEncoder→AcceleratedVideoEncoder（默认关，需显式开启硬编）。
          # 笔记本为 Intel i5-13500H 混合架构（4P+8E）+ Iris Xe iGPU + RTX 3050 PRIME offload，
          # Brave 默认跑在 Intel iGPU 上，VA-API 正常（H264/HEVC/VP9/AV1 硬解 + H264/HEVC/VP9 硬编）。
          # 勿用 --ignore-gpu-blocklist（NVIDIA 混构下易崩溃）。
          # 如需强制 N 卡渲染（牺牲 VA-API），用环境变量 __NV_PRIME_RENDER_OFFLOAD=1。
          "--enable-features=AcceleratedVideoEncoder"

          # 2. 隐私底线（其余由 policy 接管）
          "--disable-crash-reporter" # 禁用崩溃上报进程
          "--disable-speech-api" # 禁用语音识别接口

          # 3. 极简启动（跳过首次运行引导）
          "--no-first-run"
          "--no-default-browser-check"
        ];
      };
    };
}
