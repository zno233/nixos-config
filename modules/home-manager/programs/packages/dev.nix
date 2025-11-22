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
      ipython
      jupyterlab
      matplotlib
    ]))   
    ##java
    jdk
  ];
}
