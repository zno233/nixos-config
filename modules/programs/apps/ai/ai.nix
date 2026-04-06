{ inputs, ... }:
{
  flake.modules.homeManager.ai = {
    imports = with inputs.self.modules.homeManager; [
      gemini-cli
      #ollama
    ];
  };
}
