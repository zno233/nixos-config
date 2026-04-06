{ lib, ... }:
{
  options.flake.meta = lib.mkOption {
    type = lib.types.attrsOf lib.types.anything;
    default = { };
  };

  config.flake.meta = {
    # 多用户配置
    users = {
      zno = {
        homeDirectory = "/home/zno";
        email = "zno233@outlook.com";
        configDirectory = "/home/zno/zno-config";
      };
      alice = {
        homeDirectory = "/home/alice";
        email = "alice@example.com";
        configDirectory = "/home/alice/alice-config";
      };
    };

    # 默认主用户
    mainUser = "zno";
  };
}
