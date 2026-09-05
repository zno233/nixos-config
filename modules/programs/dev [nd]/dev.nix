{ inputs, ... }:
{
  flake.modules.homeManager.dev = {
    imports = with inputs.self.modules.homeManager; [
      dev-tools
      direnv
      git
      lazygit
      nvim
      tomcat
      helix
      zed
    ];
  };
}
