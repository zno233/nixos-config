{
  flake.modules.homeManager.discord =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        # discord
        # (discord.override {
        #  withVencord = true;
        # })
        webcord-vencord
      ];
    };
}
