{ config, lib, ... }:
let
  # 用户元数据的共享 submodule 类型
  userMeta = {
    options = {
      name = lib.mkOption {
        type = lib.types.str;
        description = "Username (auto-derived from the attribute key)";
      };
      homeDirectory = lib.mkOption { type = lib.types.str; };
      email = lib.mkOption { type = lib.types.str; };
      configDirectory = lib.mkOption { type = lib.types.str; };
    };
  };
in
{
  options.flake.meta = lib.mkOption {
    type = lib.types.submodule {
      options = {
        users = lib.mkOption {
          type = lib.types.attrsOf (lib.types.submodule userMeta);
          default = { };
          description = "User metadata configurations, keyed by username";
        };
        # 选择器：主用户的用户名（字符串）
        mainUserName = lib.mkOption {
          type = lib.types.str;
          default = "zno";
          description = "Username of the main user (selector for mainUser)";
        };
        # 解析后的主用户完整记录
        mainUser = lib.mkOption {
          type = lib.types.submodule userMeta;
          description = "Resolved metadata of the main user";
        };
      };
    };
    default = { };
    description = "Global metadata configuration";
  };

  config.flake.meta = {
    # mainUser 由 mainUserName 自动解析，两处永远一致
    mainUser = config.flake.meta.users.${config.flake.meta.mainUserName};

    users =
      let
        base = {
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
      in
      # 自动注入 name 字段，与 attr key 强一致
      lib.mapAttrs (name: v: { inherit name; } // v) base;
  };
}
