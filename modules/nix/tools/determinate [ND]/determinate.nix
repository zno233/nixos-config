{
  inputs,
  ...
}:
{
  flake.modules.darwin.determinate = {
    imports = [ inputs.determinate.darwinModules.default ];
    nix.enable = false; # Determinate Nix handles the Nix configuration
  };

  # On NixOS the module keeps the stock nix.* module alive (it redirects the
  # generated nix.conf to /etc/nix/nix.custom.conf and det-nixd includes it),
  # and sets nix.package itself — do NOT set nix.package anywhere else.
  flake.modules.nixos.determinate = {
    imports = [ inputs.determinate.nixosModules.default ];

    # Opt out of Determinate telemetry (device check-ins, feature stats).
    systemd.services.nix-daemon.environment.DETSYS_IDS_TELEMETRY = "disabled";

    # Disable crash reports to Determinate's Sentry.
    environment.etc."determinate/config.json".text = builtins.toJSON {
      telemetry.sentry.endpoint = null;
    };
  };
}
