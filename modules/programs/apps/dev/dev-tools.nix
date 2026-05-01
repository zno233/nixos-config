{
  flake.modules.homeManager.dev-tools =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        ## Lsp
        nixd # nix

        ## formating
        shfmt
        treefmt
        nixfmt # nixfmt-rfc-style has been replaced by nixfmt

        ## C / C++
        gcc
        gdb
        gef
        cmake
        gnumake
        valgrind
        llvmPackages_20.clang-tools

        ## Python
        #python3
        (python313.withPackages (
          p: with p; [
            #ai tools
            # llm
            # llm-ollama
            # llm-gemini

            # 核心工具
            ipython
            jupyterlab

            # 数据处理与可视化
            matplotlib
            numpy
            pandas
            seaborn
            statsmodels
            shap
            ipywidgets

            # 机器学习与数据科学
            scikit-learn
            xgboost
            joblib
            # imbalanced-learn
            chardet

            # 其他
            # mlxtend
            opencv4
            git-filter-repo
          ]
        ))

        ##java
        jdk

        # IDE
        vscode-fhs
        # android-studio
        jetbrains.idea

        # JSP
        # tomcat9
      ];
    };
}
