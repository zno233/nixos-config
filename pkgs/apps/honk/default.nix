# honk — prebuilt glibc build from the Zakkaus/doona release assets (no compilation).
#
# Every doona release attaches honk-core archives that carry the native API
# (Glassyiris/honk debug tags; HONK-SOURCE.txt in that release names the commit).
# Update: bump `release`, `version` and `hashes` from that release's SHA256SUMS.
#
# Asset name parts (doona docs, "Install honk"):
#   <arch>-unknown-linux-gnu    glibc build (this package). NixOS has no FHS
#                               /lib64/ld-linux or libstdc++, so autoPatchelfHook
#                               rewrites the interpreter and rpath.
#   <arch>-unknown-linux-musl   static build, needs no patching at all.
#   (no suffix)                 mimalloc allocator (default)
#   -stock                      the system allocator instead
{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
}:

let
  # the doona release the honk-core archives are attached to
  release = "v0.1.0-beta.16";
  # honk build tag; the binary reports it from `honk --version`
  version = "debug.2026.10.6.native-api.1";

  arch =
    let
      cpu = stdenv.hostPlatform.parsed.cpu.name;
    in
    assert lib.assertMsg (builtins.elem cpu [
      "x86_64"
      "aarch64"
    ]) "honk: no prebuilt archive for ${cpu} (only x86_64/aarch64)";
    cpu;

  # sha256 of honk-core-debug-<arch>-unknown-linux-gnu.tar.gz, from SHA256SUMS
  hashes = {
    x86_64 = "sha256-ZGyPckahmyMBQaAGf4hl92LRfLleNV1rbq8auW3gCTQ=";
    aarch64 = "sha256-u3d19+0BYh8od9p0adxopjvK7/d+1bh+X7WnwFh8Hw4=";
  };

  target = "${arch}-unknown-linux-gnu";
  archive = "honk-core-debug-${target}";
in
stdenv.mkDerivation {
  pname = "honk";
  inherit version;

  src = fetchurl {
    url = "https://github.com/Zakkaus/doona/releases/download/${release}/${archive}.tar.gz";
    hash = hashes.${arch};
  };

  # the archive has a single top-level directory; skip the auto-detection
  sourceRoot = ".";

  dontConfigure = true;
  dontBuild = true;

  # The archive's ELF needs /lib64/ld-linux-x86-64.so.2, libstdc++.so.6,
  # libgcc_s.so.1, libm.so.6 and libc.so.6. The hook takes the interpreter
  # from the stdenv's dynamic-linker and treats libm/libc as libc deps, so
  # only libstdc++/libgcc_s have to come from buildInputs.
  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [ stdenv.cc.cc.lib ];

  installPhase = ''
    runHook preInstall

    install -Dm755 ${archive}/honk-core "$out/bin/honk"
    install -Dm644 ${archive}/LICENSE "$out/share/doc/honk/LICENSE"
    install -Dm644 ${archive}/README.md "$out/share/doc/honk/README.md"

    runHook postInstall
  '';

  meta = {
    description = "Linux high-performance transparent proxy solution based on eBPF (prebuilt native-api build)";
    homepage = "https://github.com/Glassyiris/honk";
    license = lib.licenses.gpl3Only;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    mainProgram = "honk";
  };
}
