{
  flake.modules.homeManager.note-apps =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        obsidian
        zorite # gpui daily journal
      ];
    };
}
