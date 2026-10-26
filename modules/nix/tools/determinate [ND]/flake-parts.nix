{
  # Determinate Nix is Determinate Systems' validated and secure downstream distribution of NixOS/nix.
  # https://determinate.systems/nix/
  # https://docs.determinate.systems/guides/nix-darwin/

  flake-file.inputs = {
    # Determinate module — semver selector "*": auto-latest across majors,
    # chasing eval-perf improvements (lazy-trees/parallel-eval) upstream.
    determinate = {
      url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
