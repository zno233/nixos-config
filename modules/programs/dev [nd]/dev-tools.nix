{
  flake.modules.homeManager.dev-tools =
    {
      pkgs,
      ...
    }:
    {
      home.packages = with pkgs; [
        ## ── LSP / Formatting ────────────────────────────────────────
        nixd # Nix LSP
        nixfmt # Nix formatter (RFC style)
        shfmt # Shell formatter
        treefmt # multi-language formatter

        ## ── C / C++ ─────────────────────────────────────────────────
        gcc
        gdb
        gef # GDB enhanced
        cmake
        gnumake
        valgrind
        llvmPackages.clang-tools

        ## ── Python ──────────────────────────────────────────────────
        (python314.withPackages (
          p: with p; [
            # core
            ipython
            jupyterlab

            # data science
            matplotlib
            numpy
            pandas
            seaborn
            statsmodels
            ipywidgets

            # ML
            # scikit-learn
            # xgboost
            # joblib
            # imbalanced-learn

            # utils
            opencv4
            git-filter-repo
            rapidocr-onnxruntime # OCR

            # AI
            # llm
            # llm-ollama
            # llm-gemini

            # misc
            # shap
            # chardet
            # mlxtend
          ]
        ))

        ## ── Java ────────────────────────────────────────────────────
        jdk21
        # tomcat9

        ## ── IDE ─────────────────────────────────────────────────────
        vscode-fhs
        jetbrains.idea
        # android-studio

        ## ── Misc ────────────────────────────────────────────────────
        # postman
        # mysql84
        # ciscoPacketTracer9
      ];

      # 创建一个长期使用的软链接，避免因更新导致的路径漂移
      home.file."dev/toolkits/java/jdks/jdk-21".source = pkgs.jdk21;
    };
}
