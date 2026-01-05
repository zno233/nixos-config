{
  pkgs,
  inputs,
  meta,
  ...
}:
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];
  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    extraSpecialArgs = { inherit inputs meta; };
    users.${meta.userName} = {
      imports =
        if (meta.hostName == "desktop") then
          [ ../../../home/desktop ]
        else
          [ ../../../home/laptop ];
      home.username = "${meta.userName}";
      home.homeDirectory = "/home/${meta.userName}";
      home.stateVersion = "25.05";
      programs.home-manager.enable = true;
    };
    backupFileExtension = "hm-backup";
  };

  users.users.${meta.userName} = {
    isNormalUser = true;
    description = "${meta.userName}";
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
      "audio"
    ];
    shell = pkgs.zsh;
  };
  nix.settings.allowed-users = [ "${meta.userName}" ];
}
