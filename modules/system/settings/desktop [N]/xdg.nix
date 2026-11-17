{
  flake.modules.nixos.xdg =
    {
      lib,
      pkgs,
      ...
    }:
    {
      xdg.terminal-exec = {
        enable = true;
        package = pkgs.xdg-terminal-exec;
        settings =
          let
            my_terminal_desktop = [
              # NOTE: We have add these packages at user level
              "kitty.desktop"
              "com.mitchellh.ghostty.desktop"
              "Alacritty.desktop"
              "foot.desktop"
            ];
          in
          {
            GNOME = my_terminal_desktop ++ [
              "com.raggesilver.BlackBox.desktop"
              "org.gnome.Terminal.desktop"
            ];
            default = my_terminal_desktop;
          };
      };
      xdg = {
        autostart.enable = lib.mkDefault true;
        menus.enable = lib.mkDefault true;
        mime.enable = lib.mkDefault true;
        icons.enable = lib.mkDefault true;
      };

      # 这里只放所有会话共用的 portal 部分。
      # 每种桌面自己的实现（ScreenCast / Screenshot / RemoteDesktop …）跟着
      # 各自的会话模块走，避免在全局给一个已停用的合成器装 portal：
      #   modules/programs/de [nd]/wm/niri/niri.nix       → xdg.portal.config.niri
      #   modules/programs/de [nd]/wm/umbriel/umbriel.nix → xdg.portal.config.umbriel
      xdg.portal = {
        enable = true;

        # Sets environment variable NIXOS_XDG_OPEN_USE_PORTAL to 1
        # This will make xdg-open use the portal to open programs,
        # which resolves bugs involving programs opening inside FHS envs or with unexpected env vars set from wrappers.
        # xdg-open is used by almost all programs to open a unknown file/uri
        # alacritty as an example, it use xdg-open as default, but you can also custom this behavior
        # and vscode has open like `External Uri Openers`
        xdgOpenUsePortal = true;
        extraPortals = with pkgs; [
          xdg-desktop-portal-gtk # for provides file picker / OpenURI
        ];
      };
    };
}
