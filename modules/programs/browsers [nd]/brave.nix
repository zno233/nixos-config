{
  inputs,
  ...
}:
{
  flake.modules.nixos.brave =
    {
      ...
    }:
    let
      chromeStore = "https://clients2.google.com/service/update2/crx";

      # toJSON 输出纯 JSON，此处的注释不会进文件
      bravePolicies = {
        # --- 账户、遥测与诊断 ---
        BrowserSignin = 0; # 禁用账户登录
        SyncDisabled = true;
        MetricsReportingEnabled = false; # Chrome 指标上报
        BraveStatsPingEnabled = false; # 每日用量 ping
        BraveP3AEnabled = false; # Brave 匿名统计
        BuiltInDnsClientEnabled = false; # 使用系统 DNS
        UserFeedbackAllowed = false;
        FeedbackSurveysEnabled = false;
        SafeBrowsingExtendedReportingEnabled = false; # 基础 Safe Browsing 仍保留
        AlternateErrorPagesEnabled = false; # 禁用纠错页

        # --- 进程与功能裁剪 ---
        BackgroundModeEnabled = false; # 关窗即退出全部进程
        TranslateEnabled = false;
        SpellCheckServiceEnabled = false; # 本地词典拼写仍可用
        ExternalProtocolDialogShowAlwaysOpenCheckbox = true;

        # --- Brave debloat ---
        BraveAIChatEnabled = false; # Leo AI
        BraveWalletDisabled = true; # 钱包 / Web3
        BraveRewardsDisabled = true; # Rewards / BAT
        BraveVPNDisabled = true;
        BraveTalkDisabled = true; # 视频会议
        BraveNewsDisabled = true; # 新标签页新闻流
        # BravePlaylistEnabled = false;
        BraveSpeedreaderEnabled = false;
        BraveWaybackMachineEnabled = false;
        BraveWebDiscoveryEnabled = false;
        TorDisabled = true;

        # --- 指纹与隐私增强 ---
        BraveDeAmpEnabled = true; # 剥离 AMP 重定向
        BraveDebouncingEnabled = true; # 剥离跟踪跳转
        BraveReduceLanguageEnabled = true; # 精简请求头语言指纹
        DefaultBraveFingerprintingV2Setting = 3; # 1=关 3=标准

        # --- 追踪防护与连接 ---
        BraveGlobalPrivacyControlEnabled = true; # GPC：Do Not Sell/Share 信号
        BraveTrackingQueryParametersFilteringEnabled = true; # 剥 utm_* 等查询参数
        HttpsUpgradesEnabled = true;
        BlockThirdPartyCookies = true;
        SearchSuggestEnabled = false; # 避免按键泄漏给搜索服务
        WebRtcIPHandling = "disable_non_proxied_udp"; # 防 WebRTC 泄露真实 IP

        # 预取：0=所有网络预取，2=禁用；1 自 Chrome 52 起等同 0（即仍预取）
        NetworkPredictionOptions = 1;

        # --- 自动填充（交给 Bitwarden）---
        AutofillAddressEnabled = false;
        AutofillCreditCardEnabled = false;
        PasswordManagerEnabled = false;

        # --- 扩展 ---
        # force_installed = 装机即装且不可停用；normal_installed = 装机即装但可停用
        ExtensionSettings = {
          "*" = {
            installation_mode = "allowed"; # 其余仅手动安装
          };

          # force_installed
          "nngceckbapebfimnlniiiahkandclblb" = {
            # Bitwarden
            installation_mode = "force_installed";
            update_url = chromeStore;
          };
          "fnaicdffflnofjppbagibeoednhnbjhg" = {
            # Floccus（书签同步）
            installation_mode = "force_installed";
            update_url = chromeStore;
          };
          "hfjbmagddngcpeloejdejnfgbamkjaeg" = {
            # Vimium C（键盘导航）
            installation_mode = "force_installed";
            update_url = chromeStore;
          };

          # normal_installed
          "bifgfhokfobhebifcogneljkpaaloonp" = {
            # Gesturefy（鼠标手势）
            installation_mode = "normal_installed";
            update_url = chromeStore;
          };
          "jfedfbgedapdagkghmgibemcoggfppbb" = {
            # cat-catch
            installation_mode = "normal_installed";
            update_url = chromeStore;
          };
          "mpkodccbngfoacfalldjimigbofkhgjn" = {
            # Aria2 Explorer
            installation_mode = "normal_installed";
            update_url = chromeStore;
          };
          "ndcooeababalnlpkfedmmbbbgkljhpjf" = {
            # scriptcat
            installation_mode = "normal_installed";
            update_url = chromeStore;
          };
          "oopkfefbgecikmfbbapnlpjidoomhjpl" = {
            # BewlyCat
            installation_mode = "normal_installed";
            update_url = chromeStore;
          };

          # 备选（当前未启用）
          # "gcalenpjmijncebpfijmoaglllgpjagf" # Tampermonkey BETA
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

      environment.etc."brave/policies/managed/00-privacy-debloat.json".text =
        builtins.toJSON bravePolicies;
    };

  flake.modules.homeManager.chromium =
    {
      pkgs,
      ...
    }:
    {
      programs.chromium = {
        enable = true;
        package = pkgs.brave-origin;
        commandLineArgs = [
          # Wayland 原生窗口
          "--ozone-platform=wayland"
          # Linux 上 kDefaultEnableGpuRasterization 默认 DISABLED，需显式打开
          "--enable-gpu-rasterization"
          # GpuPreferences 默认 false；开了可省一次 CPU↔GPU 上传拷贝
          "--enable-zero-copy"

          # 别在这里加 --enable-features：同名 switch 取最后一个（last-wins），
          # 而本数组排在 nixpkgs wrapper 之后，会整串覆盖上游的硬解/硬编特性。
          # 需要额外 feature 请走 chrome://flags（落在 argv 最末的 flag-switches 段）。

          # 关掉常驻的辅助进程
          "--disable-crash-reporter"
          "--disable-speech-api"

          # 跳过首次运行引导
          "--no-first-run"
          "--no-default-browser-check"
        ];
      };
    };
}
