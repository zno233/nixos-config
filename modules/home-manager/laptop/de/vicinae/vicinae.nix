{ inputs, ... }:
{
  imports = [ inputs.vicinae.homeManagerModules.default ];

  services.vicinae = {
    enable = false;
    autoStart = true;
  };

  xdg.configFile."vicinae/vicinae.json".source = ./vicinae.json;
  xdg.configFile."vicinae/themes/gruvbox-dark-hard.json".source = ./gruvbox-dark-hard.json;
}
