{ inputs, ... }:
{
  flake.modules.homeManager.dev = {
    imports = with inputs.self.modules.homeManager; [
      dev-tools
      git
      lazygit
      nvim
      tomcat
      helix
    ];
  };
}
