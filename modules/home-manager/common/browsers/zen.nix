{ inputs, pkgs, ... }:
{
  imports = [ inputs.zen-browser.homeModules.beta ];

  programs.zen-browser.enable = true;
  programs.zen-browser.suppressXdgMigrationWarning = true;
}
