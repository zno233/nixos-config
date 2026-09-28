{
  flake.modules.homeManager.ssh = {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      # 易变的主机定义放本地普通文件，不进 nix/store，改动无需 rebuild
      includes = [ "~/.ssh/local" ];
      settings = {
        "*" = {
          addKeysToAgent = "1h";

          controlMaster = "auto";
          controlPath = "~/.ssh/control-%r@%h:%p";
          controlPersist = "10m";

          forwardAgent = false;
          compression = false;
          serverAliveInterval = 60;
          serverAliveCountMax = 3;
          hashKnownHosts = false;
          userKnownHostsFile = "~/.ssh/known_hosts";
        };

        github = {
          host = "github.com";
          hostname = "ssh.github.com";
          user = "git";
          port = 443;
          identityFile = "~/.ssh/id_ed25519";
          identitiesOnly = true;
        };
      };
    };

    services.ssh-agent.enable = false;
  };
}
