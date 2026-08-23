{ inputs, ... }:
{
  flake.modules.homeManager.zsh = {
    imports = with inputs.self.modules.homeManager; [
      zsh_base
      zsh_alias
      zsh_keybinds
    ];
  };
}
