# Generic AI-agent sandboxing via agent-sandbox.nix
# https://github.com/archie-judd/agent-sandbox.nix
#
# Declare agents under programs.agentSandbox.agents.<name>;
# each becomes a wrapped binary (outName, default = binName) in home.packages.
# Missing declared paths (rw or ro) refuse launch — activation pre-creates them.
# Unwrapped mode: each agent also gets <outName>-unwrapped, which exports the
# same env and execs the real binary with no sandbox; addUnwrapped.enable = false
# on an agent drops it (addUnwrapped.name renames it).
{
  inputs,
  ...
}:
{
  flake-file.inputs = {
    agent-sandbox = {
      url = "github:archie-judd/agent-sandbox.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.modules.homeManager.agent-sandbox =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      sbx = inputs.agent-sandbox.lib.${pkgs.stdenv.hostPlatform.system};
      cfg = config.programs.agentSandbox;

      # Runtime paths use $HOME; expand for activation mkdir.
      expandHome = path: lib.replaceStrings [ "$HOME" ] [ config.home.homeDirectory ] path;

      agentModule =
        {
          name,
          config,
          ...
        }:
        {
          options = {
            enable = lib.mkOption {
              type = lib.types.bool;
              default = true;
              description = "Whether to install this sandboxed agent.";
            };
            pkg = lib.mkOption {
              type = lib.types.package;
              description = "Package that contains the binary to wrap.";
            };
            binName = lib.mkOption {
              type = lib.types.str;
              description = "Name of the binary inside pkg/bin.";
            };
            outName = lib.mkOption {
              type = lib.types.str;
              default = config.binName;
              description = "Installed command name (wrapper replaces the raw binary).";
            };
            addUnwrapped = {
              enable = lib.mkOption {
                type = lib.types.bool;
                default = true;
                description = ''
                  Whether to also install an unsandboxed companion command:
                  same declared env, original binary, no sandbox.
                '';
              };
              name = lib.mkOption {
                type = lib.types.str;
                default = "${config.outName}-unwrapped";
                description = "Command name of the unsandboxed companion.";
              };
            };
            allowedPackages = lib.mkOption {
              type = lib.types.listOf lib.types.package;
              default = sbx.commonTools;
              description = "Binaries on the agent PATH inside the sandbox.";
            };
            rwDirs = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
              description = "Directories the agent may read and write ($HOME/... ok).";
            };
            rwFiles = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
              description = "Files the agent may read and write.";
            };
            roDirs = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
              description = "Directories the agent may read only.";
            };
            roFiles = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
              description = "Files the agent may read only.";
            };
            env = lib.mkOption {
              type = lib.types.attrsOf lib.types.str;
              default = { };
              description = ''
                Env vars forwarded into the sandbox. Values are shell expressions
                expanded at launch; use "''${VAR:-}" for optional vars so an
                unset host var does not refuse the launch.
              '';
            };
            allowedDomains = lib.mkOption {
              type = lib.types.nullOr (
                lib.types.either (lib.types.listOf lib.types.str) (
                  lib.types.attrsOf (lib.types.either lib.types.str (lib.types.listOf lib.types.str))
                )
              );
              default = null;
              description = "null = open internet; [] = none; list/attrs = allowlist.";
            };
            allowUnixSockets = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = "Allow AF_UNIX sockets (disabled by default for safety).";
            };
            allowedHostPorts = lib.mkOption {
              type = lib.types.nullOr (lib.types.listOf lib.types.port);
              default = [ ];
              description = "Host-local TCP ports reachable from the sandbox; null = all.";
            };
            publishedPorts = lib.mkOption {
              type = lib.types.listOf (
                lib.types.either lib.types.port (
                  lib.types.submodule {
                    options = {
                      port = lib.mkOption { type = lib.types.port; };
                      bindAddr = lib.mkOption {
                        type = lib.types.str;
                        default = "127.0.0.1";
                      };
                    };
                  }
                )
              );
              default = [ ];
              description = "Sandbox listen ports published to the host.";
            };
            allowNix = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = ''
                Expose nix-daemon + full store. Requires allowUnixSockets = true.
                Refuses to launch when the user is in trusted-users (e.g. @wheel).
              '';
            };
          };
        };

      enabledAgents = lib.filterAttrs (_: agent: agent.enable) cfg.agents;

      wrappers = lib.mapAttrsToList (
        _: agent:
        sbx.mkSandbox {
          inherit (agent)
            pkg
            binName
            outName
            allowedPackages
            rwDirs
            rwFiles
            roDirs
            roFiles
            env
            allowedDomains
            allowUnixSockets
            allowedHostPorts
            publishedPorts
            allowNix
            ;
        }
      ) enabledAgents;

      # Escape hatch for the occasional run that needs the normal environment:
      # same declared env as the sandbox (values are shell expressions
      # expanded at launch, exactly as the stub does), then a direct exec.
      mkUnwrappedWrapper =
        # mapAttrsToList passes name: value.
        _name: agent:
        pkgs.writeShellScriptBin agent.addUnwrapped.name ''
          declare_env() {
            local name=$1 expression=$2 value
            if value=$(eval "printf '%s' $expression" 2>/dev/null); then
              export "$name=$value"
            else
              printf '[agent-sandbox] %s = %s did not resolve; left unset\n' \
                "$name" "$expression" >&2
            fi
          }
          ${lib.concatStrings (
            lib.mapAttrsToList (
              name: value:
              "declare_env ${lib.escapeShellArg name} ${lib.escapeShellArg (builtins.toJSON value)}\n"
            ) agent.env
          )}
          exec ${lib.getExe' agent.pkg agent.binName} "$@"
        '';

      unwrappedAgents = lib.filterAttrs (_: agent: agent.addUnwrapped.enable) enabledAgents;

      # profile buildEnv would only say "collision"; fail at eval instead.
      unwrappedClashes = lib.filterAttrs (
        _: agent: agent.addUnwrapped.name == agent.outName
      ) unwrappedAgents;

      unwrappedWrappers =
        assert lib.assertMsg (unwrappedClashes == { })
          "[agent-sandbox] addUnwrapped.name must differ from outName for: ${lib.concatStringsSep ", " (lib.attrNames unwrappedClashes)}";
        lib.mapAttrsToList mkUnwrappedWrapper unwrappedAgents;

      # Every declared path must exist at launch — agent-sandbox refuses a
      # launch whose roFiles/roDirs are missing too, not just rw targets.
      declaredDirs = lib.unique (
        map expandHome (
          lib.concatLists (
            lib.mapAttrsToList (
              _: agent: agent.rwDirs ++ agent.roDirs ++ map dirOf (agent.rwFiles ++ agent.roFiles)
            ) enabledAgents
          )
        )
      );

      declaredFiles = lib.unique (
        map expandHome (
          lib.concatLists (lib.mapAttrsToList (_: agent: agent.rwFiles ++ agent.roFiles) enabledAgents)
        )
      );
    in
    {
      options.programs.agentSandbox = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Install sandboxed wrappers for declared agents.";
        };
        agents = lib.mkOption {
          type = lib.types.attrsOf (lib.types.submodule agentModule);
          default = { };
          description = "Agents to wrap; attr name is informational, outName sets the command.";
        };
      };

      config = lib.mkIf cfg.enable {
        home.packages = wrappers ++ unwrappedWrappers;

        # agent-sandbox refuses launch when any declared path is missing.
        # After linkGeneration, so a file Home Manager links (the git identity
        # from programs/dev/git.nix) already exists and the touch below is a
        # no-op; it only backstops paths nothing else creates.
        home.activation.createAgentSandboxPaths = lib.hm.dag.entryAfter [ "linkGeneration" ] (
          lib.concatMapStrings (dir: ''mkdir -p "${dir}"'' + "\n") declaredDirs
          + lib.concatMapStrings (
            file: ''[ -e "${file}" ] || { mkdir -p "$(dirname "${file}")"; touch "${file}"; }'' + "\n"
          ) declaredFiles
        );
      };
    };
}
