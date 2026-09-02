#!/usr/bin/env bash
# update.sh — 更新 asuka-fonts 的 version 和 hash
#
# 用法:
#   ./update.sh              # 自动检测最新 release
#   ./update.sh v0.2.0       # 指定版本
#   ./update.sh --check      # 仅检查当前版本是否为最新，不修改文件
#
# 依赖: curl, jq, nix-prefetch-url
#   nix-shell -p curl jq nix-prefetch-url --run ./update.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NIX_FILE="${SCRIPT_DIR}/default.nix"
REPO="zno233/asuka-fonts"
FONT_NAMES=(
  AsukaMono-Light.ttf
  AsukaMono-Regular.ttf
  AsukaMono-Bold.ttf
  AsukaSans-Light.ttf
  AsukaSans-Regular.ttf
  AsukaSans-Bold.ttf
)

# ── 颜色 ──
red()   { printf '\033[0;31m%s\033[0m\n' "$*"; }
green() { printf '\033[0;32m%s\033[0m\n' "$*"; }
bold()  { printf '\033[1m%s\033[0m\n' "$*"; }

# ── 依赖检查 ──
for cmd in curl jq nix-prefetch-url; do
  if ! command -v "$cmd" &>/dev/null; then
    red "错误: 缺少 $cmd"
    echo "运行: nix-shell -p curl jq nix-prefetch-url --run \"\$0 $*\""
    exit 1
  fi
done

# ── 获取最新 release tag ──
get_latest_tag() {
  local resp
  resp="$(curl -sL "https://api.github.com/repos/${REPO}/releases/latest")"
  if echo "$resp" | jq -e '.tag_name' &>/dev/null; then
    echo "$resp" | jq -r '.tag_name'
  else
    # fallback: 从 tags 列表取最新的 v* tag
    local tags
    tags="$(curl -sL "https://api.github.com/repos/${REPO}/git/matching-refs/tags/v" \
      | jq -r '.[].ref' | sed 's|refs/tags/||' | sort -V)"
    if [[ -n "$tags" ]]; then
      echo "$tags" | tail -1
    else
      red "错误: ${REPO} 没有 release 也没有 v* tag"
      echo "请等 CI 构建完成后再运行此脚本"
      exit 1
    fi
  fi
}

# ── 获取指定 release 的所有 asset 文件名 ──
get_release_assets() {
  local tag="$1"
  local resp
  resp="$(curl -sL "https://api.github.com/repos/${REPO}/releases/tags/${tag}")"
  if echo "$resp" | jq -e '.assets' &>/dev/null; then
    echo "$resp" | jq -r '.assets[].name'
  else
    echo "$resp" | jq -r '.message // "未知错误"'
    return 1
  fi
}

# ── 计算单个文件的 SRI hash ──
prefetch_hash() {
  local url="$1"
  local raw_hash
  raw_hash="$(nix-prefetch-url --type sha256 "$url" 2>/dev/null | tail -1)"
  nix hash to-sri --type sha256 "$raw_hash"
}

# ── 生成 default.nix ──
generate_nix() {
  local version="$1"
  local -n _hashes=$2

  cat <<EOF
{
  lib,
  stdenvNoCC,
  fetchurl,
}:

let
  version = "${version}";
  baseUrl = "https://github.com/${REPO}/releases/download/v\${version}";

  fonts = [
    # Asuka Mono (等宽 — 终端/代码)
    {
      name = "AsukaMono-Light.ttf";
      hash = "${_hashes[AsukaMono-Light.ttf]}";
    }
    {
      name = "AsukaMono-Regular.ttf";
      hash = "${_hashes[AsukaMono-Regular.ttf]}";
    }
    {
      name = "AsukaMono-Bold.ttf";
      hash = "${_hashes[AsukaMono-Bold.ttf]}";
    }
    # Asuka Sans (比例 — 阅读/文档)
    {
      name = "AsukaSans-Light.ttf";
      hash = "${_hashes[AsukaSans-Light.ttf]}";
    }
    {
      name = "AsukaSans-Regular.ttf";
      hash = "${_hashes[AsukaSans-Regular.ttf]}";
    }
    {
      name = "AsukaSans-Bold.ttf";
      hash = "${_hashes[AsukaSans-Bold.ttf]}";
    }
  ];
in
stdenvNoCC.mkDerivation {
  pname = "asuka-fonts";
  inherit version;

  srcs = map (
    font:
    fetchurl {
      url = "\${baseUrl}/\${font.name}";
      pname = font.name;
      inherit (font) hash;
    }
  ) fonts;

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    mkdir -p \$out/share/fonts/truetype

    for src in \$srcs; do
      install -Dm644 "\$src" "\$out/share/fonts/truetype/\$(basename "\$src")"
    done

    runHook postInstall
  '';

  meta = with lib; {
    description = "Iosevka-based font with Nerd Font icons and non-Latin character support";
    homepage = "https://github.com/${REPO}";
    license = with licenses; [
      ofl11 # Iosevka, LXGW WenKai, WenYuan Rounded
      mit # Nerd Fonts
    ];
    platforms = platforms.all;
  };
}
EOF
}

# ── 从现有文件中提取 version ──
get_current_version() {
  grep -oP 'version = "\K[^"]+' "$NIX_FILE" | head -1
}

# ── 主流程 ──
main() {
  local target_tag=""
  local check_only=false

  case "${1:-}" in
    --check)
      check_only=true
      ;;
    v*|""|*)
      target_tag="${1:-}"
      ;;
  esac

  # 获取目标版本
  if [[ -z "$target_tag" ]]; then
    bold "正在查询 ${REPO} 最新 release..."
    target_tag="$(get_latest_tag)"
    if [[ -z "$target_tag" || "$target_tag" == "null" ]]; then
      red "错误: 无法获取最新 release（可能还没有 release）"
      exit 1
    fi
  fi
  green "目标版本: ${target_tag}"

  # check 模式
  if $check_only; then
    local current
    current="$(get_current_version)"
    if [[ "v${current}" == "$target_tag" ]]; then
      green "当前版本 ${current} 已是最新"
      exit 0
    else
      echo "当前版本: v${current} → 最新: ${target_tag}"
      exit 1
    fi
  fi

  # 验证 release 存在且包含字体文件
  bold "正在验证 release assets..."
  local available_assets
  available_assets="$(get_release_assets "$target_tag")" || {
    red "错误: release ${target_tag} 尚未创建"
    echo "请等 CI 构建完成后再运行此脚本"
    exit 1
  }

  local missing=()
  for name in "${FONT_NAMES[@]}"; do
    if ! echo "$available_assets" | grep -qx "$name"; then
      missing+=("$name")
    fi
  done

  if [[ ${#missing[@]} -gt 0 ]]; then
    red "错误: release ${target_tag} 缺少以下文件:"
    for f in "${missing[@]}"; do
      echo "  - $f"
    done
    echo ""
    echo "该 release 包含的文件:"
    echo "$available_assets"
    exit 1
  fi
  green "所有 ${#FONT_NAMES[@]} 个字体文件均已就绪"

  # 下载并计算 hash
  bold "正在下载并计算 hash..."
  declare -A hashes
  local base_url="https://github.com/${REPO}/releases/download/${target_tag}"

  for name in "${FONT_NAMES[@]}"; do
    printf '  %-30s' "$name"
    hashes["$name"]="$(prefetch_hash "${base_url}/${name}")"
    green "${hashes[$name]}"
  done

  # 生成并写入文件
  bold "正在写入 ${NIX_FILE}..."
  generate_nix "${target_tag#v}" hashes > "$NIX_FILE"

  green "完成! ${NIX_FILE} 已更新"
  echo ""
  bold "验证构建:"
  echo "  nix build .#asuka-fonts --no-link --print-out-paths"
}

main "$@"
