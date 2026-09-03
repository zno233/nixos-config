{
  self,
  ...
}:
{
  flake.modules.nixos.greetd =
    { pkgs, ... }:
    {
      services.greetd = {
        enable = true;
        settings = {
          terminal.vt = 1;
          # 开机自动登录，登出后回到 tuigreet 选择界面
          # initial_session = {
          #   command = "${pkgs.niri}/bin/niri-session";
          #   user = "zno";
          # };
          # default_session = {
          #   command = "${pkgs.tuigreet}/bin/tuigreet --time --time-format \"%H:%M  %Y-%m-%d\" --remember --remember-session --asterisks --greeting \"welcome to NixOS\" --cmd ${pkgs.niri}/bin/niri-session";
          #   user = "greeter";
          # };
        };
      };
      # 登录时解锁 GPG keyring
      security.pam.services.greetd.enableGnomeKeyring = true;
      # 创建目录链接，将 niri 会话添加到 Wayland 会话列表中
      environment.pathsToLink = [ "/share/wayland-sessions" ];
    };
}
