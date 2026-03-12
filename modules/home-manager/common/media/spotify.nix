{ inputs, pkgs, ... }:
let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
{
  # 导入模块
  imports = [ inputs.spicetify-nix.homeManagerModules.default ];

  programs.spicetify = {
    enable = true;

    # 1. 选择主题
    # 使用 Gruvbox 主题
    theme = spicePkgs.themes.lucid;
    colorScheme = "";

    # 2. 添加插件 (包括你刚才问的广告屏蔽)
    enabledExtensions = with spicePkgs.extensions; [
      adblock # 屏蔽广告
      shuffle # 真正的随机播放
      hidePodcasts # 隐藏播客
      # fullAppDisplay     # 专辑封面全屏显示
      # beautifulLyrics    # 歌词
    ];

    # 3. 启用自定义功能
    # enabledCustomApps = with spicePkgs.apps; [
    #   marketplace        # 在 Spotify 界面里直接下载更多主题和插件
    # ];
  };
}
