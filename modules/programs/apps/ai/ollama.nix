{
  flake.modules.homeManager.ollama =
    { pkgs, ... }:
    {
      home.packages = [
        (pkgs.ollama.override {
          acceleration = "cuda";
        })
      ];
    };
}
