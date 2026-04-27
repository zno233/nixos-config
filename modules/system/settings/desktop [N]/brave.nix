{ inputs, ... }:
{
  flake.modules.nixos.brave =
    { ... }:
    let
      # 带注释的 policies（toJSON 会自动生成纯 JSON）
      bravePolicies = {
        # --- 核心隐私与安全（与原 Chromium 一致） ---
        BrowserSignin = 0; # 禁用登录，保护隐私
        SyncDisabled = true; # 彻底禁用同步引擎
        MetricsReportingEnabled = false; # 禁用指标上报
        BackgroundModeEnabled = false; # 关闭浏览器后立即释放所有进程

        # 加强遥测/诊断关闭
        BraveStatsPingEnabled = false;

        # --- 禁用自动填充（交给 Bitwarden） ---
        AutofillAddressEnabled = false;
        AutofillCreditCardEnabled = false;
        PasswordManagerEnabled = false;

        # --- 网络隐私与连接（通用） ---
        BuiltInDnsClientEnabled = false; # 使用系统 DNS
        AlternateErrorPagesEnabled = false; # 禁用纠错页面

        # --- 易用性 ---
        ExternalProtocolDialogShowAlwaysOpenCheckbox = true;

        # --- Privacy Sandbox（通用） ---
        PrivacySandboxAdTopicsEnabled = false;
        PrivacySandboxAdMeasurementEnabled = false;
        PrivacySandboxSiteEnabledAdsEnabled = false;
        PrivacySandboxPromptEnabled = false;

        # --- GenAI / AI 禁用（Chromium 风格，Brave 上部分生效） ---
        CreateThemesSettings = 2;
        HelpMeWriteSettings = 2;
        HistorySearchSettings = 2;

        # --- Brave 专属彻底 debloat ---
        BraveAIChatEnabled = false; # 禁用 Leo AI
        BraveWalletDisabled = true; # 禁用数字钱包 + Web3
        BraveRewardsDisabled = true; # 禁用 Rewards / BAT / 隐私广告
        BraveVPNDisabled = true; # 禁用 VPN 提示
        BraveP3AEnabled = false; # 禁用匿名统计（P3A）
        BraveTalkDisabled = true; # 禁用 Brave Talk（视频会议）

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

          # 辅助扩展：自动安装 + 可手动开关（这就是你想要的“安装但是可控”）
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
          "gcalenpjmijncebpfijmoaglllgpjagf" = {
            # Tampermonkey BETA
            installation_mode = "normal_installed";
            update_url = "https://clients2.google.com/service/update2/crx";
          };
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
        package = pkgs.brave;

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
          # 加强隐私（禁用崩溃上报、后台网络、限制 WebRTC IP 泄露）
          "--disable-crash-reporter"
          "--disable-background-networking"
          "--force-webrtc-ip-handling-policy=disable_non_proxied_udp"

          # 3. 极简启动（跳过烦人的首次运行引导）
          "--no-first-run"
          "--no-default-browser-check"

          # 4. Brave 辅助 debloat
          "--disable-features=BraveAIChat,BraveWallet,BraveRewards,BraveP3A"
        ];

        # 核心插件：隐私、密码、易用性、书签同步等
        # 通过注释/取消注释 extensions 列表来切换安装方式（与 policy 二选一）
        # extensions = [
        #   # 隐私安全
        #   # "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin
        #   # { id = "ddkjiahejlhfcafbddmgiahcphecmpfh"; } # uBlock Origin Lite

        #   # 账号与同步
        #   { id = "nngceckbapebfimnlniiiahkandclblb"; } # Bitwarden
        #   { id = "fnaicdffflnofjppbagibeoednhnbjhg"; } # Floccus（书签同步）

        #   # 效率工具
        #   { id = "hfjbmagddngcpeloejdejnfgbamkjaeg"; } # Vimium C
        #   { id = "bifgfhokfobhebifcogneljkpaaloonp"; } # Cesturefy（鼠标手势）

        #   # B 站专属（按需取消注释）
        #   # "bbbiejemhfihiooipfcjmjmbfdmobobp" # BewlyBewly
        #   # "eaoelafamejbnggahofapllmfhlhajdd" # 小电视空降助手

        #   # 下载/开发
        #   { id = "jfedfbgedapdagkghmgibemcoggfppbb"; } # cat-catch
        #   { id = "mpkodccbngfoacfalldjimigbofkhgjn"; } # Aria2 Explorer
        #   # "cclelndahbckbenkjhflpdbgdldlbecc" # Get cookies.txt

        #   # 其他
        #   { id = "gcalenpjmijncebpfijmoaglllgpjagf"; } # Tampermonkey BETA
        #   # "mpiodijhokgodhhofbcjdecpffjipkle" # SingleFile
        #   # "bhchdcejhohfmigjafbampogmaanbfkg" # User-Agent Switcher and Manager
        #   # "iifacdnjakkhjjiengaffnegbndgingi" # Voyager
        # ];
      };
    };
}
