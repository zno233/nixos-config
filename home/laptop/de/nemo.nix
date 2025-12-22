{ pkgs, ... }:
{
  home.packages = with pkgs; [ nemo-with-extensions ];

  xdg.dataFile = {
    # 1. 在当前目录打开 Kitty 的 Action
    "nemo/actions/kitty_here.nemo_action".text = ''
      [Nemo Action]
      Name=Open in Kitty
      Comment=Open kitty terminal in the current directory
      Exec=kitty --directory %F
      Icon-Name=utilities-terminal
      Selection=any
      Extensions=dir;
      Quote=double
    '';

    # 2. 使用 unar 解压文件的 Action
    "nemo/actions/unar_extract.nemo_action".text = ''
      [Nemo Action]
      Name=Extract with unar
      Comment=Extract archive (supports passwords in terminal)
      Exec=kitty --hold sh -c "unar -o %P %F"
      Icon-Name=archive-extract
      Selection=s
      Extensions=zip;7z;rar;tar;gz;bz2;
      Quote=double
    '';
  };

  dconf.settings = {
    "org/nemo/preferences" = {
      always-use-browser = true;
      # click-double-parent-folder = true;
      close-device-view-on-device-eject = true;
      date-font-choice = "auto-mono";
      date-format = "iso";
      last-server-connect-method = 3;
      quick-renames-with-pause-in-between = true;
      show-edit-icon-toolbar = false;
      show-full-path-titles = false;
      show-hidden-files = true;
      show-home-icon-toolbar = true;
      show-new-folder-icon-toolbar = true;
      show-open-in-terminal-toolbar = false;
      show-search-icon-toolbar = false;
      show-show-thumbnails-toolbar = false;
      thumbnail-limit = 10485760;
    };
    "org/nemo/preferences/menu-config" = {
      background-menu-open-as-root = false;
      selection-menu-open-as-root = false;
      selection-menu-open-in-terminal = false;
      selection-menu-scripts = false;
    };
    "org/nemo/search" = {
      search-reverse-sort = false;
      search-sort-column = "name";
    };
    "org/nemo/window-state" = {
      maximized = true;
      network-expanded = true;
      side-pane-view = "places";
      sidebar-bookmark-breakpoint = 2;
      sidebar-width = 220;
      start-with-sidebar = true;
    };
  };
}
