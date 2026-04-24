{
  flake.modules.nixos.chromium =
    { pkgs, ... }:
    let
      # 使用 Wrapper，通过override的方式迁移 Flags：将 chrome://flags 转换为声明式启动参数
      my-chromium = pkgs.chromium.override {
        enableWideVine = true; # 必须启用，否则无法看 Netflix/B站高码率
        commandLineArgs = [
          # 1. 核心硬件加速
          "--enable-gpu-rasterization"
          "--enable-zero-copy"
          "--ignore-gpu-blocklist"
          "--enable-features=VaapiVideoDecoder,CanvasOopRasterization,ParallelDownloading"

          # 2. 核心隐私底线
          "--no-pings" # 禁用超链接点击追踪
          "--disable-speech-api" # 禁用不需要的语音识别接口
          "--disable-domain-reliability" # 禁用域名可靠性报告

          # 3. 极简启动（跳过烦人的首次运行引导）
          "--no-first-run"
          "--no-default-browser-check"
        ];
      };
    in
    {
      # 1.. 显式安装
      environment.systemPackages = [ my-chromium ];
      # 2. 配置 Chromium 插件、选项等
      programs.chromium = {
        enable = true;

        # 核心插件：隐私、密码、易用性、书签同步等，注释插件最好于store下载保留灵活性
        extensions = [
          # 隐私安全
          # "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin
          "ddkjjiahejlhfcafbddmgiahcphecmpfh" # uBlock Origin lite
          # "fjkmabmdepjfammlpliljpnbhleegehm" # WebRTC Control

          # 账号与同步
          "nngceckbapebfimnlniiiahkandclblb" # Bitwarden
          "fnaicdffflnofjppbagibeoednhnbjhg" # Floccus

          # 效率工具
          "hfjbmagddngcpeloejdejnfgbamkjaeg" # Vimium C
          "jlgkpaicikihijadgifklkbpdajbkhjo" # CrxMouse

          # B 站专属
          # "bbbiejemhfihiooipfcjmjmbfdmobobp" # BewlyBewly
          # "eaoelafamejbnggahofapllmfhlhajdd" # 小电视空降助手

          # 下载/开发
          "jfedfbgedapdagkghmgibemcoggfppbb" # cat-catch
          "mpkodccbngfoacfalldjimigbofkhgjn" # Aria2 Explorer
          # "cclelndahbckbenkjhflpdbgdldlbecc" # Get cookies.txt

          # 其他
          "gcalenpjmijncebpfijmoaglllgpjagf" # Tampermonkey BETA
          # "mpiodijhokgodhhofbcjdecpffjipkle" # SingleFile
          # "bhchdcejhohfmigjafbampogmaanbfkg" # User-Agent Switcher and Manager
          # "iifacdnjakkhjjiengaffnegbndgingi" # Voyager
        ];

        # 额外选项：隐私、密码、易用性等
        extraOpts = {
          # --- 核心隐私与安全 ---
          "BrowserSignin" = 0; # 禁用登录，保护隐私
          "SyncDisabled" = true; # 彻底禁用同步引擎
          "MetricsReportingEnabled" = false; # 禁用指标上报

          # --- 禁用生成式 AI 功能 (GenAI) ---
          # 2 表示强制禁用
          "GenAiDefaultSettings" = 2;
          "CreateThemesSettings" = 2; # 禁用 AI 生成主题
          "TabOrganizerSettings" = 2; # 禁用 AI 标签页分组
          "HelpMeWriteSettings" = 2; # 禁用 AI 辅助写作
          "HistorySearchSettings" = 2; # 禁用 AI 智能历史搜索

          # --- 禁用自动填充 ---
          "AutofillAddressEnabled" = false;
          "AutofillCreditCardEnabled" = false;
          "PasswordManagerEnabled" = false; # 禁用自带密码管家，交给 Bitwarden

          # --- 网络隐私与连接 ---
          "BuiltInDnsClientEnabled" = false; # 禁用内置 DNS，使用系统 DNS
          "AlternateErrorPagesEnabled" = false; # 禁用 Google 纠错页面

          # --- 易用性与本地化 ---
          "ApplicationLocaleValue" = "zh-CN"; # 界面强制中文
          "ExternalProtocolDialogShowAlwaysOpenCheckbox" = true; # 外部协议链接直接打开

          # --- 性能与后台控制 ---
          "BackgroundModeEnabled" = false; # 关闭浏览器后立即释放所有进程

          # === 补充：Privacy Sandbox 原子策略 ===
          "PrivacySandboxAdTopicsEnabled" = false; # 禁用 Topics API
          "PrivacySandboxAdMeasurementEnabled" = false; # 禁用广告测量
          "PrivacySandboxSiteEnabledAdsEnabled" = false; # 禁用站点广告
          "PrivacySandboxPromptEnabled" = false; # 禁用隐私沙箱提示
        };
      };
    };
}
