{
  inputs,
  ...
}:
{
  # flake-file.inputs = {
  #   zed.url = "github:zed-industries/zed";
  # };

  flake.modules.homeManager.zed =
    {
      pkgs,
      ...
    }:
    {
      programs.zed-editor = {
        enable = true;
        package = pkgs.zed-editor;
        extensions = [
          "nix"
          "toml"
          "rust"
          "everforest"
        ];
        userSettings = {
          theme = {
            mode = "system"; # 跟随系统
            dark = "Everforest Dark Hard (material)";
            light = "Everforest Light Hard (material)";
          };

          agent = {
            sidebar_side = "right";
            favorite_models = [ ];
            model_parameters = [ ];
          };

          project_panel = {
            dock = "left";
          };

          base_keymap = "VSCode";
          vim_mode = false;

          show_whitespaces = "all"; # 显示空白字符
          load_direnv = "shell_hook"; # 支持 flake.nix 环境
          auto_update = false;

          ui_font_size = 20;
          buffer_font_size = 18;

          telemetry = {
            metrics = false; # 关闭遥测
          };

          languages = {
            "Nix" = {
              language_servers = [ "nixd" ];
            };
          };
        };
      };

      home.shellAliases = {
        zed = "zeditor";
      };
    };
}
