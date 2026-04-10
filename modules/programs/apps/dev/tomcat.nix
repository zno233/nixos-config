{
  flake.modules.homeManager.tomcat =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      tomcatDevPath = "${config.home.homeDirectory}/dev/tomcat-dev";
    in
    {
      # 环境变量
      home.sessionVariables = {
        CATALINA_HOME = tomcatDevPath;
        CATALINA_BASE = tomcatDevPath;
      };

      # 可选：添加到PATH
      # home.sessionPath = [ "${tomcatDevPath}/bin" ];

      # 在用户目录直接创建（可写！）
      home.activation.setupTomcat = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
                TOMCAT_DEV="${tomcatDevPath}"
                
                # 创建可写目录
                $DRY_RUN_CMD mkdir -p $TOMCAT_DEV/{logs,temp,work,webapps}
                
                # 符号链接只读资源
                $DRY_RUN_CMD ln -sfn ${pkgs.tomcat9}/bin $TOMCAT_DEV/bin
                $DRY_RUN_CMD ln -sfn ${pkgs.tomcat9}/lib $TOMCAT_DEV/lib
                
                # 复制配置（仅首次，避免覆盖用户修改）
                if [ ! -d "$TOMCAT_DEV/conf" ]; then
                  $DRY_RUN_CMD cp -r ${pkgs.tomcat9}/conf $TOMCAT_DEV/conf
                  $DRY_RUN_CMD chmod -R u+w $TOMCAT_DEV/conf
                fi
                
                # 创建启动脚本
                $DRY_RUN_CMD cat > $TOMCAT_DEV/startup.sh << 'SCRIPT'
        #!/usr/bin/env bash
        export CATALINA_HOME="$(dirname "$(readlink -f "$0")")"
        export CATALINA_BASE="$CATALINA_HOME"
        export JAVA_HOME="${pkgs.jdk}"
        echo "🚀 启动Tomcat..."
        echo "   CATALINA_HOME: $CATALINA_HOME"
        echo "   JAVA_HOME: $JAVA_HOME"
        exec "$CATALINA_HOME/bin/catalina.sh" run
        SCRIPT
                $DRY_RUN_CMD chmod +x $TOMCAT_DEV/startup.sh
                
                $DRY_RUN_CMD cat > $TOMCAT_DEV/shutdown.sh << 'SCRIPT'
        #!/usr/bin/env bash
        export CATALINA_HOME="$(dirname "$(readlink -f "$0")")"
        export CATALINA_BASE="$CATALINA_HOME"
        exec "$CATALINA_HOME/bin/catalina.sh" stop
        SCRIPT
                $DRY_RUN_CMD chmod +x $TOMCAT_DEV/shutdown.sh
                
                echo "✅ Tomcat开发环境已就绪: $TOMCAT_DEV"
      '';
    };
}
