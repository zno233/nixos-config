{
  flake.modules.homeManager.agent-cli =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        gemini-cli
        opencode
        qwen-code
      ];
    };
}
