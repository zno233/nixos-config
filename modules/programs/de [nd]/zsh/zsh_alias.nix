{
  flake.modules.homeManager.zsh_alias = {
    programs.zsh = {
      shellAliases = {
        # Navigation / shell
        c = "clear";
        cd = "z"; # zoxide

        # Files & directories
        l = "eza --icons -a --group-directories-first -1 --no-user --long"; # EZA_ICON_SPACING=2
        tree = "eza --icons --tree --group-directories-first";
        dsize = "du -hs";
        space = "ncdu";
        open = "xdg-open";
        copy = "wl-copy";
        tt = "gtrash put";

        # Viewers
        cat = "bat";
        less = "bat"; # same as cat
        man = "batman";
        diff = "delta --diff-so-fancy --side-by-side"; # git diff (gd) uses side-by-side = false

        # Editors
        nano = "hx";
        code = "zeditor"; # duplicate of `zed` (defined in dev/zed.nix)

        # Info
        ff = "fastfetch";

        # Language
        py = "python";
        ipy = "ipython";
        icat = "kitten icat";
      };
    };
  };
}
