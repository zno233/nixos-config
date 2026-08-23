{ ... }:
{
  flake.modules.homeManager.agent_alias =
    { config, pkgs, ... }:
    {
      programs.zsh = {
        initContent = ''
          claude-ds() {
            # 直接读取 NixOS 系统级解密后的固定路径
            # 确保此路径与 configuration.nix 中定义的 path 一致
            local secret_path="/run/agenix/deepseek-token"

            if [ -f "$secret_path" ]; then
              export ANTHROPIC_AUTH_TOKEN=$(cat "$secret_path")
            else
              echo "错误：未找到 Token 文件，请检查 /run/agenix/deepseek-token 是否存在且权限正确。"
              return 1
            fi

            export ANTHROPIC_BASE_URL=https://api.deepseek.com/anthropic
            export ANTHROPIC_MODEL="deepseek-v4-pro[1m]"
            export ANTHROPIC_DEFAULT_OPUS_MODEL="deepseek-v4-pro[1m]"
            export ANTHROPIC_DEFAULT_SONNET_MODEL="deepseek-v4-pro[1m]"
            export ANTHROPIC_DEFAULT_HAIKU_MODEL="deepseek-v4-flash"
            export CLAUDE_CODE_SUBAGENT_MODEL="deepseek-v4-flash"
            export CLAUDE_CODE_EFFORT_LEVEL=max

            claude
          }
        '';
      };
    };
}
