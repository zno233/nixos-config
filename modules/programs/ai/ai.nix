{ inputs, ... }:
{
  flake.modules.homeManager.ai = {
    imports = with inputs.self.modules.homeManager; [
      agent
      agent_alias
      #ollama
    ];
  };
}
