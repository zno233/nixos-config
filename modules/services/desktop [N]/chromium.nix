{ inputs, ... }:
{
  flake.modules.nixos.chromium =
    { ... }:
    let
      # 带注释的 policies（toJSON 会自动生成纯 JSON，无注释）
      chromiumPolicies = {
        # --- 核心隐私与安全 ---
        BrowserSignin = 0; # 禁用登录，保护隐私
        SyncDisabled = true; # 彻底禁用同步引擎
        MetricsReportingEnabled = false; # 禁用指标上报

        # --- 禁用生成式 AI 功能 (GenAI) ---
        GenAiDefaultSettings = 2; # 2 表示强制禁用
        CreateThemesSettings = 2; # 禁用 AI 生成主题
        HelpMeWriteSettings = 2; # 禁用 AI 辅助写作
        HistorySearchSettings = 2; # 禁用 AI 智能历史搜索

        # --- 禁用自动填充 ---
        AutofillAddressEnabled = false;
        AutofillCreditCardEnabled = false;
        PasswordManagerEnabled = false; # 禁用自带密码管家，交给 Bitwarden

        # --- 网络隐私与连接 ---
        BuiltInDnsClientEnabled = false; # 使用系统 DNS
        AlternateErrorPagesEnabled = false; # 禁用 Google 纠错页面

        # --- 易用性与本地化 ---
        ExternalProtocolDialogShowAlwaysOpenCheckbox = true;

        # --- 性能与后台控制 ---
        BackgroundModeEnabled = false; # 关闭浏览器后立即释放所有进程

        # === 补充：Privacy Sandbox 原子策略 ===
        PrivacySandboxAdTopicsEnabled = false;
        PrivacySandboxAdMeasurementEnabled = false;
        PrivacySandboxSiteEnabledAdsEnabled = false;
        PrivacySandboxPromptEnabled = false;
      };
    in
    {
      home-manager.sharedModules = [
        inputs.self.modules.homeManager.chromium
      ];

      # 系统级声明 policies
      environment.etc."chromium/policies/managed/policy.json".text = builtins.toJSON chromiumPolicies;
    };

  flake.modules.homeManager.chromium =
    { pkgs, ... }:
    {
      programs.chromium = {
        enable = true;
        package = pkgs.chromium.override {
          enableWideVine = true;
        };
        commandLineArgs = [
          # 1. 核心硬件加速
          "--enable-gpu-rasterization"
          "--enable-zero-copy"
          "--ignore-gpu-blocklist"
          "--enable-features=VaapiVideoDecoder,CanvasOopRasterization,ParallelDownloading,EncryptedMediaExtensions"

          # 2. 核心隐私底线
          "--no-pings" # 禁用超链接点击追踪
          "--disable-speech-api" # 禁用不需要的语音识别接口
          "--disable-domain-reliability" # 禁用域名可靠性报告

          # 3. 极简启动（跳过烦人的首次运行引导）
          "--no-first-run"
          "--no-default-browser-check"
        ];

        # 核心插件：隐私、密码、易用性、书签同步等，注释插件最好于store下载保留灵活性
        extensions = [
          # 隐私安全
          # "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin
          { id = "ddkjiahejlhfcafbddmgiahcphecmpfh"; } # uBlock Origin Lite
          # "fjkmabmdepjfammlpliljpnbhleegehm" # WebRTC Control

          # 账号与同步
          { id = "nngceckbapebfimnlniiiahkandclblb"; } # Bitwarden
          { id = "fnaicdffflnofjppbagibeoednhnbjhg"; } # Floccus

          # 效率工具
          { id = "hfjbmagddngcpeloejdejnfgbamkjaeg"; } # Vimium C
          { id = "jlgkpaicikihijadgifklkbpdajbkhjo"; } # CrxMouse

          # B 站专属
          # "bbbiejemhfihiooipfcjmjmbfdmobobp" # BewlyBewly
          # "eaoelafamejbnggahofapllmfhlhajdd" # 小电视空降助手

          # 下载/开发
          { id = "jfedfbgedapdagkghmgibemcoggfppbb"; } # cat-catch
          { id = "mpkodccbngfoacfalldjimigbofkhgjn"; } # Aria2 Explorer
          # "cclelndahbckbenkjhflpdbgdldlbecc" # Get cookies.txt

          # 其他
          { id = "gcalenpjmijncebpfijmoaglllgpjagf"; } # Tampermonkey BETA
          # "mpiodijhokgodhhofbcjdecpffjipkle" # SingleFile
          # "bhchdcejhohfmigjafbampogmaanbfkg" # User-Agent Switcher and Manager
          # "iifacdnjakkhjjiengaffnegbndgingi" # Voyager
        ];
      };
    };
}
