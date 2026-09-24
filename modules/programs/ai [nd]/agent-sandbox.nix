# Generic AI-agent sandboxing via agent-sandbox.nix
# https://github.com/archie-judd/agent-sandbox.nix
#
# Declare agents under programs.agentSandbox.agents.<name>;
# each becomes a wrapped binary (outName, default = binName) in home.packages.
# Missing rwDirs/rwFiles refuse launch — activation pre-creates them.
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

      # Declared paths must exist at launch; create rw targets on activation.
      declaredDirs = lib.unique (
        map expandHome (
          lib.concatLists (
            lib.mapAttrsToList (_: agent: agent.rwDirs ++ map dirOf agent.rwFiles) enabledAgents
          )
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
        home.packages = wrappers;

        # agent-sandbox refuses launch when a declared rw path is missing.
        home.activation.createAgentSandboxDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] (
          lib.concatMapStrings (dir: ''mkdir -p "${dir}"'' + "\n") declaredDirs
        );
      };
    };
}
