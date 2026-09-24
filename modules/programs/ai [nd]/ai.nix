{
  inputs,
  ...
}:
{
  flake.modules.homeManager.ai = {
    imports = with inputs.self.modules.homeManager; [
      agent-sandbox # defines programs.agentSandbox before agent declares agents
      agent
      agent_alias
      #ollama
    ];
  };
}
