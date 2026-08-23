{
  self,
  ...
}:
{
  flake-file.inputs = {
    llm-agents.url = "github:numtide/llm-agents.nix";
  };

  flake.modules.homeManager.agent =
    { pkgs, ... }:
    {
      home.packages = with self.inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
        claude-code
        opencode
        reasonix
        # gemini-cli
        # qwen-code
      ];
    };
}
