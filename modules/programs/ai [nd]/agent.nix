{
  inputs,
  ...
}:
{
  flake-file.inputs = {
    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.modules.homeManager.agent =
    {
      pkgs,
      ...
    }:
    {
      home.packages = with inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
        claude-code
        opencode
        dsh
        # gemini-cli
        # qwen-code
      ];
    };
}
