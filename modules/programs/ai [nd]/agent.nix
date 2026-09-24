# AI coding agents — declared once, installed as agent-sandbox wrappers.
# To add an agent: one entry under programs.agentSandbox.agents (see agent-sandbox.nix).
{
  inputs,
  ...
}:
{
  flake-file.inputs = {
    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.modules.homeManager.agent =
    {
      pkgs,
      ...
    }:
    let
      agentsPkgs = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
    in
    {
      # Optional host tokens/aliases (claude-ds, etc.) must be listed here or
      # they never enter the sandbox. Unset vars use ''${VAR:-} so launch still works.
      programs.agentSandbox.agents = {
        claude-code = {
          pkg = agentsPkgs.claude-code;
          binName = "claude";
          rwDirs = [ "$HOME/.claude" ];
          roFiles = [
            "$HOME/.config/git/config"
            "$HOME/.config/git/.gitignore"
          ];
          env = {
            # Keep config inside the rwDir (avoids ~/.claude.json rename races).
            CLAUDE_CONFIG_DIR = "$HOME/.claude";
            CLAUDE_CODE_OAUTH_TOKEN = "\${CLAUDE_CODE_OAUTH_TOKEN:-}";
            GITHUB_TOKEN = "\${GITHUB_TOKEN:-}";
            # claude-ds() exports these before invoking claude.
            ANTHROPIC_AUTH_TOKEN = "\${ANTHROPIC_AUTH_TOKEN:-}";
            ANTHROPIC_BASE_URL = "\${ANTHROPIC_BASE_URL:-}";
            ANTHROPIC_MODEL = "\${ANTHROPIC_MODEL:-}";
            ANTHROPIC_DEFAULT_OPUS_MODEL = "\${ANTHROPIC_DEFAULT_OPUS_MODEL:-}";
            ANTHROPIC_DEFAULT_SONNET_MODEL = "\${ANTHROPIC_DEFAULT_SONNET_MODEL:-}";
            ANTHROPIC_DEFAULT_HAIKU_MODEL = "\${ANTHROPIC_DEFAULT_HAIKU_MODEL:-}";
            CLAUDE_CODE_SUBAGENT_MODEL = "\${CLAUDE_CODE_SUBAGENT_MODEL:-}";
            CLAUDE_CODE_EFFORT_LEVEL = "\${CLAUDE_CODE_EFFORT_LEVEL:-}";
          };
          # allowedDomains = null (open). Tighten per README when needed.
        };

        opencode = {
          pkg = agentsPkgs.opencode;
          binName = "opencode";
          rwDirs = [
            "$HOME/.config/opencode"
            "$HOME/.local/share/opencode"
            "$HOME/.local/state/opencode"
            "$HOME/.cache/opencode"
          ];
          roFiles = [
            "$HOME/.config/git/config"
            "$HOME/.config/git/.gitignore"
          ];
          env = {
            ANTHROPIC_API_KEY = "\${ANTHROPIC_API_KEY:-}";
            OPENAI_API_KEY = "\${OPENAI_API_KEY:-}";
            DEEPSEEK_API_KEY = "\${DEEPSEEK_API_KEY:-}";
            GITHUB_TOKEN = "\${GITHUB_TOKEN:-}";
          };
        };

        # DeepSeek Harness — state lives under $DSH_HOME (default ~/.dsh).
        dsh = {
          pkg = agentsPkgs.dsh;
          binName = "dsh";
          rwDirs = [ "$HOME/.dsh" ];
          roFiles = [
            "$HOME/.config/git/config"
            "$HOME/.config/git/.gitignore"
          ];
          env = {
            DSH_HOME = "$HOME/.dsh";
            DEEPSEEK_API_KEY = "\${DEEPSEEK_API_KEY:-}";
            ANTHROPIC_AUTH_TOKEN = "\${ANTHROPIC_AUTH_TOKEN:-}";
            ANTHROPIC_BASE_URL = "\${ANTHROPIC_BASE_URL:-}";
            GITHUB_TOKEN = "\${GITHUB_TOKEN:-}";
          };
        };

        # To enable later, copy an entry above and uncomment:
        # gemini-cli = {
        #   pkg = agentsPkgs.gemini-cli;
        #   binName = "gemini";
        #   rwDirs = [ "$HOME/.config/gemini" "$HOME/.cache/gemini" ];
        # };
        # qwen-code = {
        #   pkg = agentsPkgs.qwen-code;
        #   binName = "qwen";
        #   rwDirs = [ "$HOME/.qwen" "$HOME/.config/qwen" ];
        # };
      };
    };
}
