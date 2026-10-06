# NixOS module for honk — lives next to the package (pkgs/apps/honk).
# Wired into service-desktop via modules/services/desktop [N]/honk.nix.
#
# Based on the upstream daeuniverse honk module (official style), with:
# - package via mkPackageOption pkgs "honk" (this repo's overlay)
# - ui option and the api.dae/doona wiring from the old module
{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkOption
    literalExpression
    types
    optional
    optionalString
    getExe
    mkPackageOption
    ;

  cfg = config.services.honk-core;
  inherit (cfg) assets;

  genAssetsDrv =
    paths:
    pkgs.symlinkJoin {
      name = "honk-assets";
      inherit paths;
    };

  # Native API block shared by both wiring paths (inline bake / config.d
  # include): honk serves doona's static UI at /ui/, same origin as /api.
  nativeApiText = ui: ''
    # Every native_api field needs a restart; a reload rejects changes.
    experimental {
        native_api {
            enabled: true
            # Loopback only; set a LAN address (e.g. 192.168.1.1:9527) to reach doona from other hosts.
            listen: '127.0.0.1:9527'
            # Administrator password login. For token mode, delete this
            # line and set secret instead; the two cannot be combined.
            password_auth: true
            # secret: 'replace-with-a-long-random-token'
            # doona's config page writes sources through the engine (If-Match)
            config_write: true
            ui: '${ui}/share/doona'
            # On by default; listed so the names are known.
            record_flows: true
            record_traffic: true
            record_memory: true
            record_logs: true
            record_dns_log: true
        }
    }
  '';

  apiDae = pkgs.writeText "api.dae" (nativeApiText cfg.ui);
in
{
  options = {
    services.honk-core = {
      enable = mkEnableOption "honk, a Linux high-performance transparent proxy solution based on eBPF";

      package = mkPackageOption pkgs "honk" { };

      assets = mkOption {
        type = with types; (listOf path);
        default = with pkgs; [
          v2ray-geoip
          v2ray-domain-list-community
        ];
        defaultText = literalExpression "with pkgs; [ v2ray-geoip v2ray-domain-list-community ]";
        description = "Assets required to run honk.";
      };

      assetsPath = mkOption {
        type = types.str;
        default = "${genAssetsDrv assets}/share/v2ray";
        defaultText = literalExpression ''
          "''${(symlinkJoin {
              name = "honk-assets";
              paths = assets;
          })}/share/v2ray"
        '';
        description = ''
          Directory containing `geoip.dat` / `geosite.dat` used as the
          first-run seed: missing files are copied from here into
          `/var/lib/honk` at service start (never overwriting files already
          there). honk loads and updates the `/var/lib/honk` copies in place,
          so doona's geodata updates survive restarts.
          This option will override `assets`.
        '';
      };

      openFirewall = mkOption {
        type = types.submodule {
          options = {
            enable = mkEnableOption "opening {option}`port` in the firewall";
            port = mkOption {
              type = types.port;
              description = ''
                Port to be opened. Consist with field `tproxy_port` in config file.
              '';
            };
          };
        };
        default = {
          enable = true;
          port = 12345;
        };
        defaultText = literalExpression ''
          {
            enable = true;
            port = 12345;
          }
        '';
        description = ''
          Open the firewall port.
        '';
      };

      configFile = mkOption {
        type =
          let
            inherit (types) nullOr addCheck str;
            isAbsolutePathString = x: lib.substring 0 1 x == "/";
            isNotInStore = x: !lib.hasPrefix builtins.storeDir x;
            combineTopic = x: isAbsolutePathString x && isNotInStore x;
          in
          (nullOr (addCheck str combineTopic))
          // {
            description = "${types.str.description} (with check: should be absolute path **string** which not a store path)";
          };
        default = null;
        example = ''"/path/to/your/config.dae"'';
        description = ''
          The absolute path string of honk config file which not in nix store,
          end with `.dae`. Will fallback to `"/etc/honk/config.dae"` if this is not set.
        '';
      };

      config = mkOption {
        type = with types; (nullOr str);
        default = null;
        description = ''
          WARNING: This option will expose your config unencrypted world-readable in the nix store.
          Config text for honk.

          See <https://github.com/daeuniverse/honk/blob/main/example.dae>.
        '';
      };

      disableTxChecksumIpGeneric = mkEnableOption "" // {
        description = "See <https://github.com/daeuniverse/dae/issues/43>";
      };

      ui = mkOption {
        type = types.nullOr types.package;
        default = null;
        example = "pkgs.doona";
        description = ''
          Static web UI package served by honk's native API at /ui/ (same origin as /api).
          When set (e.g. pkgs.doona), the module only places
          `config.d/api.dae` next to `configFile` with experimental.native_api
          enabled. The `include { config.d/*.dae }` in `configFile` is a module
          default maintained independently of this option (a legacy
          `include { api.dae }` is normalized to the glob form). The include is
          a separate file so the main file stays editable from the UI's config
          page. All native_api fields are restart-required.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      # Inline config: no external configFile for the ExecStartPre wiring to
      # hook into, so bake native_api straight into the generated text
      # (skipped when the config already mentions native_api).
      (lib.mkIf (cfg.configFile == null) {
        environment.etc."honk/config.dae" = {
          mode = "0400";
          source = pkgs.writeText "config.dae" (
            cfg.config
            + optionalString (cfg.ui != null && !(lib.hasInfix "native_api" cfg.config)) (
              "\n" + nativeApiText cfg.ui
            )
          );
        };
      })
      {
        environment.systemPackages = [ cfg.package ];
        systemd.packages = [ cfg.package ];

        networking = lib.mkIf cfg.openFirewall.enable {
          firewall =
            let
              portToOpen = cfg.openFirewall.port;
            in
            {
              allowedTCPPorts = [ portToOpen ];
              allowedUDPPorts = [ portToOpen ];
            };
        };

        # Requires root + eBPF/netadmin; do not harden until the datapath is verified.
        # Conflicts with another real datapath (e.g. daed) — only one per host.
        systemd.services.honk =
          let
            honkBin = getExe cfg.package;

            # Upstream calls getExe without parentheses around this derivation
            # (broken when the option is on); nixos dae module wraps it — do too.
            TxChecksumIpGenericWorkaround = getExe (
              pkgs.writeShellApplication {
                name = "disable-tx-checksum-ip-generic";
                text = ''
                  iface=$(${pkgs.iproute2}/bin/ip route | ${getExe pkgs.gawk} '/default/ {print $5}')
                  ${getExe pkgs.ethtool} -K "$iface" tx-checksum-ip-generic off
                '';
              }
            );

            configPath = if cfg.configFile != null then cfg.configFile else "/etc/honk/config.dae";

            # ui option: only place doona's native_api fragment. Runs on every
            # start (ExecStartPre) when ui and an external configFile are set:
            # writes config.d/api.dae. config.d is created with the parent's
            # owner/mode because UMask 0077 would otherwise make it
            # root-only inside the user's home. Paths resolve against the
            # entry config's directory and symlinks leaving it are rejected
            # -> copy, don't symlink.
            writeApiDae = pkgs.writeShellScript "honk-write-api-dae" ''
              set -eu
              cfgDir=${lib.escapeShellArg (builtins.dirOf cfg.configFile)}
              if [ ! -d "$cfgDir" ]; then
                echo "honk: config dir $cfgDir missing, skipping api.dae placement" >&2
              else
                if [ ! -d "$cfgDir/config.d" ]; then
                  ${pkgs.coreutils}/bin/mkdir -m 0755 "$cfgDir/config.d"
                  ${pkgs.coreutils}/bin/chown --reference="$cfgDir" "$cfgDir/config.d"
                  ${pkgs.coreutils}/bin/chmod --reference="$cfgDir" "$cfgDir/config.d"
                fi
                ${pkgs.coreutils}/bin/install -m 0644 ${apiDae} "$cfgDir/config.d/api.dae"
              fi
            '';

            # Module default (independent of ui): make sure the external
            # configFile carries `include { config.d/*.dae }` so drop-ins in
            # config.d/ are loaded. A zero-match glob is fine (honk's tests
            # cover missing dirs and unmatched patterns), so this stays safe
            # before config.d exists. Skips configs that set native_api
            # inline (a second definition would be rejected), and rewrites a
            # legacy `include { api.dae }` or a precise
            # `include { config.d/api.dae }` to the glob form. Runs on every
            # start (ExecStartPre) whenever an external configFile is set.
            #
            # Also enforces group write access: honk runs as root and its
            # native-API config_write replaces the file by rename, preserving
            # only the mode (never the owner), so after a doona save the main
            # config becomes root-owned. A setgid config dir + group-writable
            # mode keeps the config owner able to edit it: new files inherit
            # the dir's group and honk carries the 0664 mode through the
            # rename. config.d/api.dae stays excluded (module-managed).
            ensureInclude = pkgs.writeShellScript "honk-ensure-include" ''
              set -eu
              cfgDir=${lib.escapeShellArg (builtins.dirOf cfg.configFile)}
              mainConfig=${lib.escapeShellArg cfg.configFile}
              if [ ! -d "$cfgDir" ]; then
                echo "honk: config dir $cfgDir missing, skipping include wiring" >&2
              else
                ${pkgs.coreutils}/bin/chmod g+s,g+w "$cfgDir"
                if [ -d "$cfgDir/config.d" ]; then
                  ${pkgs.coreutils}/bin/chmod g+s,g+w "$cfgDir/config.d"
                  for dropIn in "$cfgDir"/config.d/*.dae; do
                    if [ -e "$dropIn" ] && [ "$dropIn" != "$cfgDir/config.d/api.dae" ]; then
                      ${pkgs.coreutils}/bin/chgrp --reference="$cfgDir" "$dropIn"
                      ${pkgs.coreutils}/bin/chmod g+rw "$dropIn"
                    fi
                  done
                fi
                if [ ! -f "$mainConfig" ]; then
                  echo "honk: $mainConfig missing, skipping include wiring" >&2
                else
                  ${pkgs.coreutils}/bin/chgrp --reference="$cfgDir" "$mainConfig"
                  ${pkgs.coreutils}/bin/chmod g+rw "$mainConfig"
                  if ${pkgs.gnugrep}/bin/grep -q 'native_api' "$mainConfig"; then
                    echo "honk: $mainConfig already sets native_api inline, not appending include" >&2
                  elif ${pkgs.gnugrep}/bin/grep -qF 'config.d/*.dae' "$mainConfig"; then
                    # covers the single-line and the pretty-printed multi-line form
                    :
                  elif ${pkgs.gnugrep}/bin/grep -qE '(^[[:space:]]*include[[:space:]]*[{][[:space:]]*(config\.d/api\.dae|api\.dae)|^[[:space:]]*(config\.d/api\.dae|api\.dae)[[:space:]]*$)' "$mainConfig"; then
                    owner=$(${pkgs.coreutils}/bin/stat -c %u:%g "$mainConfig")
                    mode=$(${pkgs.coreutils}/bin/stat -c %a "$mainConfig")
                    ${pkgs.gnused}/bin/sed -i -E \
                      -e 's#^[[:space:]]*include[[:space:]]*[{][[:space:]]*(config\.d/api\.dae|api\.dae).*#include {\n    config.d/*.dae\n}#' \
                      -e 's#^([[:space:]]*)(config\.d/api\.dae|api\.dae)[[:space:]]*$#\1config.d/*.dae#' \
                      "$mainConfig"
                    ${pkgs.coreutils}/bin/chown "$owner" "$mainConfig"
                    ${pkgs.coreutils}/bin/chmod "$mode" "$mainConfig"
                    ${pkgs.coreutils}/bin/rm -f "$cfgDir/api.dae"
                    echo "honk: normalized include to config.d/*.dae in $mainConfig" >&2
                  else
                    printf '\n# managed by NixOS (services.honk-core): drop-in includes\ninclude {\n    config.d/*.dae\n}\n' >> "$mainConfig"
                    echo "honk: appended include { config.d/*.dae } to $mainConfig" >&2
                  fi
                fi
              fi
            '';

            # Seed geo assets into the writable data dir. DAE_LOCATION_ASSET
            # points at /var/lib/honk, so honk loads these files and replaces
            # them in place on a geodata update — the store copy below is only
            # the first-run source and is never re-copied over a runtime
            # update. Assumes the default `global.data_dir` (/var/lib/honk).
            seedGeoAssets = pkgs.writeShellScript "honk-seed-geo-assets" ''
              set -eu
              state=/var/lib/honk
              src=${lib.escapeShellArg cfg.assetsPath}
              for name in geoip.dat geosite.dat; do
                if [ ! -e "$state/$name" ] && [ -e "$src/$name" ]; then
                  ${pkgs.coreutils}/bin/cp -L "$src/$name" "$state/$name"
                fi
              done
            '';
          in
          {
            description = "honk transparent proxy engine";
            wantedBy = [ "multi-user.target" ];
            wants = [ "network-online.target" ];
            after = [ "network-online.target" ];
            # Force a reload when the inline config text changes; external
            # configFile edits are picked up via `honk reload` manually.
            reloadTriggers = optional (cfg.config != null) cfg.config;

            serviceConfig = {
              Type = "notify";
              ExecStartPre = [
                ""
              ]
              ++ optional cfg.disableTxChecksumIpGeneric TxChecksumIpGenericWorkaround
              ++ [ seedGeoAssets ]
              ++ optional (cfg.ui != null && cfg.configFile != null) writeApiDae
              ++ optional (cfg.configFile != null) ensureInclude;
              ExecStart = [
                ""
                "${honkBin} -c ${configPath} --disable-timestamp"
              ];
              # reload asks the running instance via /run/honk-core.lock and
              # ignores -c, so no configPath here.
              ExecReload = "${honkBin} reload";
              # Writable dir, not the store: honk must replace geo files in
              # place (updates via doona) and keep loading them after a
              # restart — a store path here makes every post-restart update
              # fail with EEXIST against the shadow copy.
              Environment = "DAE_LOCATION_ASSET=/var/lib/honk";
              TimeoutStartSec = 120;
              Restart = "on-failure";
              RestartSec = "2s";
              TimeoutStopSec = "30s";
              LimitNOFILE = 1048576;
              LimitMEMLOCK = "infinity";
              UMask = "0077";
              StateDirectory = "honk";
              ConfigurationDirectory = "honk";
            };
          };

        systemd.tmpfiles.rules = [ "d /etc/honk 0755 root root -" ];

        assertions = [
          {
            assertion = lib.pathExists (toString (genAssetsDrv cfg.assets) + "/share/v2ray");
            message = ''
              Packages in `assets` has no preset path `/share/v2ray` included.
              Please set `assetsPath` instead.
            '';
          }

          {
            assertion =
              let
                A = config.services.honk-core.config == null;
                B = config.services.honk-core.configFile == null;
              in
              (A && !B) || (!A && B); # xor
            message = ''
              Either `config` or `configFile` should be only set.
            '';
          }
        ];
      }
    ]
  );
}
