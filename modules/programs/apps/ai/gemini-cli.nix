{
  flake.modules.homeManager.gemini-cli =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        gemini-cli
      ];
    };
}
