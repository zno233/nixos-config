{
  # flake.modules.homeManager.hyprlock =
  #   {
  #     config,
  #     inputs,
  #     ...
  #   }:
  #   {
  #     programs.hyprlock = {
  #       enable = true;
  #     };

  #     xdg.configFile."hyprlock" = {
  #       source = ./.hyprlock;
  #     };

  #     xdg.configFile."hypr/hyprlock.conf" = {
  #       source = ./hyprlock.conf;
  #     };
  #   };
}
