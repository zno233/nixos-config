{ lib, ... }:
{
  options.flake.meta = lib.mkOption {
    type = lib.types.submodule {
      options = {
        users = lib.mkOption {
          type = lib.types.attrsOf (
            lib.types.submodule {
              options = {
                homeDirectory = lib.mkOption { type = lib.types.str; };
                email = lib.mkOption { type = lib.types.str; };
                configDirectory = lib.mkOption { type = lib.types.str; };
              };
            }
          );
          default = { };
          description = "User metadata configurations";
        };
        mainUser = lib.mkOption {
          type = lib.types.str;
          default = "zno";
          description = "Default main user";
        };
      };
    };
    default = { };
    description = "Global metadata configuration";
  };

  config.flake.meta = {
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
    mainUser = "zno";
  };
}
