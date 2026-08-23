{
  flake.modules.homeManager.p10k =
    { ... }:
    {
      home.file.".p10k.zsh".source = ./.p10k.zsh;
    };
}
