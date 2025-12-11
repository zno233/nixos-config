{ pkgs, ... }:
{
  home.packages = with pkgs; [
    ## Lsp
    nixd # nix

    ## formating
    shfmt
    treefmt
    nixfmt-rfc-style

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
    (python312.withPackages (p: with p; [
      #ai tools
      # llm
      # llm-ollama
      # llm-gemini
      
      ipython
      jupyterlab
      matplotlib
      numpy
      pandas
      mlxtend
      seaborn
      opencv4
    ]))  
    ##java
    jdk
  ];
}
