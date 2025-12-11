{ pkgs, ... }:
{
  home.packages = [
   (pkgs.ollama.override { 
      acceleration = "cuda";
    })
  ];
}
