{
  inputs,
  ...
}:
{
  flake-file.inputs = {
    lazyvim-nix = {
      url = "github:pfassina/lazyvim-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.modules.homeManager.nvim = {
    imports = [
      inputs.lazyvim-nix.homeManagerModules.default
    ];

    programs.lazyvim = {
      enable = true;
      configFiles = ./lazyvim;
      # 隐藏 "LazyVim/LazyVim: Using source (...)" 等求值期 trace
      # ignoreBuildNotifications = true;
    };
  };
}
