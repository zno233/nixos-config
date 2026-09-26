# honk — cloned from daeuniverse/flake.nix@add-honk/honk/package.nix,
# repointed at Glassyiris/honk (feat/native-api). Differences from upstream:
#   * nightly = 2026-07-20 (the pin in crates/honk-ebpf/rust-toolchain.toml)
#   * HONK_VERSION/HONK_REVISION/HONK_TARGET are exported: the fork's lib.rs and
#     clash_api.rs use env!(), while build.rs gets stubbed out below (upstream does
#     the same stub but only wires HONK_EBPF_OBJECT)
#   * src/rev/version live here so they cannot drift apart
#   * crane + rust-overlay are pinned here as plain sources (not flake inputs),
#     so `nix flake update` never touches honk's build tooling
{
  lib,
  pkgs,
}:

let
  # --- pinned build tooling (see header); bump rev + hash here to update ---
  craneSrc = pkgs.fetchFromGitHub {
    owner = "ipetkov";
    repo = "crane";
    rev = "692f7e9ef2ece8125b466f66f2af532b3edaed0d"; # v0.24.0
    hash = "sha256-lWhBbBvC05/xwivKBBiM2YNizpmgqCgyOIzomvRuwxs=";
  };
  # identical to crane's `mkLib pkgs`: its flake.nix defines mkLib exactly this way
  craneLib = import craneSrc { inherit pkgs; };

  rustOverlaySrc = pkgs.fetchFromGitHub {
    owner = "oxalica";
    repo = "rust-overlay";
    rev = "228ecefb6329d5a531b77b46b581a2f0c26ee056"; # contains nightly 2026-07-20
    hash = "sha256-yJr1Bt4fKkKIpPYbsKGqJ0VFdoDnURgRwuffmBQ2WzY=";
  };
  # only honk needs pkgs.rust-bin: apply the overlay locally instead of globally
  # (was: inputs.rust-overlay.overlays.default in nixos-minimal.nix)
  pkgs' = pkgs.appendOverlays [ (import rustOverlaySrc) ];

  src = pkgs.fetchFromGitHub {
    owner = "Glassyiris";
    repo = "honk";
    rev = "bfe96e6af62532c1604c6446c1d1c1db3bedef80";
    hash = "sha256-i6T3smzzyU8JpWwpPR2vRxx6QoXPAuay6Ftp/ucXUig=";
  };
  version = "0.0.1-alpha";
  # what build.rs would have emitted via `git rev-parse --short=12 HEAD`
  revision = "bfe96e6af625";

  rustToolchain = pkgs'.rust-bin.nightly."2026-07-20".default.override {
    extensions = [ "rust-src" ];
  };

  bpfLinker = pkgs.rustPlatform.buildRustPackage {
    pname = "bpf-linker";
    version = "git";
    src = pkgs.fetchFromGitHub {
      owner = "aya-rs";
      repo = "bpf-linker";
      rev = "faab7946344770cd5ea3671b9878c5d6e6393dc2";
      hash = "sha256-XlKqNgQ6MzeJ/7/Ds7x9DC109QtUQsQ6u2y3gK1sW1o=";
    };
    cargoHash = "sha256-uQDXn+FfziMtZz0hwR8I5khMhAO8gt+MlO++N4OpC6I=";
    buildNoDefaultFeatures = true;
    # rustc nightly-2026-07-20 embeds LLVM 22.1.8 bitcode ("Update LLVM" landed
    # 2026-07-10); bpf-linker must be built against the same major or it fails
    # to parse objects with "ERROR llvm: Invalid record".
    # (upstream daeuniverse pairs nightly-2025-10-01 with llvm-21.)
    buildFeatures = [ "llvm-22" ];
    nativeBuildInputs = [
      pkgs.llvm_22
      pkgs.zlib
      pkgs.libxml2
      pkgs.pkg-config
    ];
    buildInputs = [
      pkgs.llvm_22.lib
      pkgs.zlib
      pkgs.libxml2
    ];
    LLVM_SYS_221_PREFIX = "${pkgs.llvm_22.dev}";
    doCheck = false;
  };

  craneLibNightly = craneLib.overrideToolchain rustToolchain;

  ebpfArgs = {
    inherit src version;
    pname = "honk-ebpf";
    nativeBuildInputs = [ bpfLinker ];
    cargoExtraArgs = "--manifest-path crates/honk-ebpf/Cargo.toml -Zbuild-std=core --target bpfel-unknown-none";
    cargoToml = "${src}/crates/honk-ebpf/Cargo.toml";
    cargoLock = "${src}/crates/honk-ebpf/Cargo.lock";
    CARGO_BUILD_RUSTFLAGS = "-C opt-level=2 -C llvm-args=-inline-threshold=300 -C linker=bpf-linker -C debuginfo=2 -C link-arg=--emit=obj -C link-arg=--llvm-args=-bpf-stack-size=4096 -C link-arg=--btf";
    cargoVendorDir = craneLibNightly.vendorMultipleCargoDeps {
      cargoConfigs = [ ];
      cargoLockList = [
        "${src}/crates/honk-ebpf/Cargo.lock"
        "${rustToolchain.passthru.availableComponents.rust-src}/lib/rustlib/src/rust/library/Cargo.lock"
      ];
    };
    doCheck = false;
    dontStrip = true;
  };

  ebpfArtifacts = craneLibNightly.buildDepsOnly ebpfArgs;

  ebpfPackage = craneLibNightly.buildPackage (
    ebpfArgs
    // {
      cargoArtifacts = ebpfArtifacts;
      doNotPostBuildInstallCargoBinaries = true;
      installPhase = ''
        runHook preInstall
        mkdir -p $out/bin
        binPath="target/bpfel-unknown-none/release/honk-ebpf"
        if [ ! -f "$binPath" ]; then
          binPath="crates/honk-ebpf/target/bpfel-unknown-none/release/honk-ebpf"
        fi
        if [ ! -f "$binPath" ]; then
          echo "Could not find honk-ebpf binary in target directories."
          find . -type f -name "honk-ebpf"
          exit 1
        fi
        cp $binPath $out/bin/honk-ebpf
        runHook postInstall
      '';
    }
  );

  commonArgs = {
    inherit src version;
    pname = "honk";

    strictDeps = true;

    nativeBuildInputs = with pkgs; [
      pkg-config
      llvmPackages.bintools
      git
      cmake
      clang
      rustPlatform.bindgenHook
    ];

    buildInputs = with pkgs; [
      openssl
    ];

    # Empty out build.rs so it doesn't try to build the eBPF object
    postPatch = ''
      if [ -f crates/honk-core/build.rs ]; then
        echo "fn main() {}" > crates/honk-core/build.rs
      fi
    '';
  };

  rustToolchainStable = pkgs'.rust-bin.stable.latest.default;
  craneLibStable = craneLib.overrideToolchain rustToolchainStable;

  cargoArtifacts = craneLibStable.buildDepsOnly commonArgs;

  package = craneLibStable.buildPackage (
    commonArgs
    // {
      inherit cargoArtifacts;
      HONK_EBPF_OBJECT = "${ebpfPackage}/bin/honk-ebpf";
      HONK_VERSION = version;
      HONK_REVISION = revision;
      HONK_TARGET = pkgs.stdenv.hostPlatform.rust.rustcTarget or "x86_64-unknown-linux-gnu";
      cargoExtraArgs = "-p honk-core --features ebpf";
      doCheck = false; # Skip tests for now as they might require networking

      postInstall = ''
        if [ -f $out/bin/honk-core ]; then
          mv $out/bin/honk-core $out/bin/honk
        fi
      '';

      meta = with lib; {
        description = "A Linux high-performance transparent proxy solution based on eBPF (honk)";
        homepage = "https://github.com/Glassyiris/honk";
        license = licenses.gpl3Only;
        platforms = platforms.linux;
        mainProgram = "honk";
      };
    }
  );
in
package
