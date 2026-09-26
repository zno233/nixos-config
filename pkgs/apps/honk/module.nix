# NixOS module for honk — lives next to the package (pkgs/apps/honk).
# Wired into service-desktop via modules/services/desktop [N]/honk.nix.
#
# Based on the upstream daeuniverse honk module (official style), with:
# - namespace `services.honk-core`: nixpkgs rename.nix reserves `services.honk`
#   (mkRemovedOptionModule) and nixpkgs `services.honk` is an unrelated
#   ActivityPub server. Upstream itself still reads config.services.honk while
#   declaring options under services.honk-proxy — use honk-core consistently.
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

  # Native API block shared by both wiring paths (inline bake / api.dae
  # include): honk serves doona's static UI at /ui/, same origin as /api.
  nativeApiText =
    ui:
    ''
      experimental {
          native_api {
              enabled: true
              listen: '127.0.0.1:9527'
              password_auth: true
              # doona's config page writes sources through the engine (If-Match)
              config_write: true
              ui: '${ui}/share/doona'
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
          The path which contains geolocation database.
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
          When set (e.g. pkgs.doona), the module writes an `api.dae` include next to
          `configFile` with experimental.native_api enabled, and appends
          `include { api.dae }` to `configFile` if it does not mention api.dae yet.
          The include is a separate file so the main file stays editable from the UI's
          config page. All native_api fields are restart-required.
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
            TxChecksumIpGenericWorkaround = getExe (pkgs.writeShellApplication {
              name = "disable-tx-checksum-ip-generic";
              text = ''
                iface=$(${pkgs.iproute2}/bin/ip route | ${getExe pkgs.gawk} '/default/ {print $5}')
                ${getExe pkgs.ethtool} -K "$iface" tx-checksum-ip-generic off
              '';
            });

            configPath = if cfg.configFile != null then cfg.configFile else "/etc/honk/config.dae";

            # Wire doona's native_api next to an external configFile. Runs on
            # every start (ExecStartPre) and is idempotent. honk resolves
            # `include { api.dae }` against the entry config's directory and
            # rejects symlinks leaving it -> copy, don't symlink. No install -D:
            # with UMask 0077 it would create the config dir root-owned inside
            # the user's home when it does not exist yet.
            wireApiDae = pkgs.writeShellScript "honk-wire-api-dae" ''
              set -eu
              cfgDir=${lib.escapeShellArg (builtins.dirOf cfg.configFile)}
              mainConfig=${lib.escapeShellArg cfg.configFile}
              if [ ! -d "$cfgDir" ]; then
                echo "honk: config dir $cfgDir missing, skipping api.dae/ui wiring" >&2
              elif [ -f "$mainConfig" ] && ${pkgs.gnugrep}/bin/grep -q 'native_api' "$mainConfig"; then
                echo "honk: $mainConfig already sets native_api inline, not appending include { api.dae }" >&2
              else
                ${pkgs.coreutils}/bin/install -m 0644 ${apiDae} "$cfgDir/api.dae"
                if [ -f "$mainConfig" ] && ! ${pkgs.gnugrep}/bin/grep -qE '^[[:space:]]*include[[:space:]]*\{[[:space:]]*api\.dae' "$mainConfig"; then
                  printf '\n# managed by NixOS (services.honk-core.ui): native API + doona frontend\ninclude { api.dae }\n' >> "$mainConfig"
                fi
              fi
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
              ExecStartPre = [ "" ]
                ++ optional cfg.disableTxChecksumIpGeneric TxChecksumIpGenericWorkaround
                ++ optional (cfg.ui != null && cfg.configFile != null) wireApiDae;
              ExecStart = [
                ""
                "${honkBin} -c ${configPath} --disable-timestamp"
              ];
              # reload asks the running instance via /run/honk-core.lock and
              # ignores -c, so no configPath here.
              ExecReload = "${honkBin} reload";
              Environment = "DAE_LOCATION_ASSET=${cfg.assetsPath}";
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
